import stripe
import json
import traceback
from flask import Blueprint, request, jsonify
from config import settings
from firebase_config import get_firestore_client
from firebase_admin import firestore
from datetime import datetime, timezone
from middleware import require_auth


def _stripe_to_dict(obj):
    """Recursively convert a StripeObject to a plain dict."""
    if hasattr(obj, '_data'):
        return {k: _stripe_to_dict(v) for k, v in obj._data.items()}
    elif isinstance(obj, list):
        return [_stripe_to_dict(item) for item in obj]
    return obj

stripe.api_key = settings.STRIPE_SECRET_KEY

stripe_bp = Blueprint("stripe", __name__, url_prefix="/stripe")


@stripe_bp.route("/create-payment-intent", methods=["POST"])
@require_auth
def create_payment_intent():
    try:
        data = request.get_json()
        amount = data.get("amount")
        payment_type = data.get("type")
        artist_id = data.get("artistId")
        performance_id = data.get("performanceId")
        # Get the authenticated user's ID so we can embed it in the
        # PaymentIntent metadata — the payment_intent.succeeded webhook
        # needs it to write the transaction record.
        user_id = request.user["uid"]

        if not amount or not payment_type or not artist_id:
            return jsonify({"error": "amount, type, and artistId are required"}), 400

        if payment_type not in ("tip", "paid_access"):
            return jsonify({"error": "type must be 'tip' or 'paid_access'"}), 400

        amount_cents = int(float(amount) * 100)

        platform_fee = int(amount_cents * (settings.PLATFORM_FEE_PERCENT / 100))

        intent = stripe.PaymentIntent.create(
            amount=amount_cents,
            currency="usd",
            automatic_payment_methods={"enabled": True},
            metadata={
                "type": payment_type,
                "artistId": artist_id,
                "performanceId": performance_id or "",
                "userId": user_id,
            },
        )

        return jsonify({
            "clientSecret": intent.client_secret,
            "paymentIntentId": intent.id,
        })
    except stripe.error.StripeError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@stripe_bp.route("/confirm-payment", methods=["POST"])
@require_auth
def confirm_payment():
    try:
        data = request.get_json()
        payment_intent_id = data.get("paymentIntentId")
        user_id = data.get("userId")
        artist_id = data.get("artistId")
        amount = data.get("amount")
        payment_type = data.get("type")
        performance_id = data.get("performanceId")

        if not payment_intent_id or not user_id or not artist_id or not amount:
            return jsonify({"error": "paymentIntentId, userId, artistId, and amount are required"}), 400

        db = get_firestore_client()
        # Check if transaction already exists
        existing = (
            db.collection("transactions")
            .where("paymentIntentId", "==", payment_intent_id)
            .limit(1)
            .get()
        )
        if list(existing):
            return jsonify({
                "success": True,
                "status": "already_confirmed"
            })

        intent = stripe.PaymentIntent.retrieve(payment_intent_id)
        if intent.status != "succeeded":
            return jsonify({"error": "Payment not successful", "status": intent.status}), 400

        amount_cents = int(float(amount) * 100)
        platform_fee = int(amount_cents * (settings.PLATFORM_FEE_PERCENT / 100))
        net_amount = amount_cents - platform_fee
        tx_ref = db.collection("transactions").document()
        tx_ref.set({
            "userId": user_id,
            "artistId": artist_id,
            "amount": amount_cents,
            "platformFee": platform_fee,
            "netAmount": net_amount,
            "type": payment_type,
            "performanceId": performance_id or "",
            "paymentIntentId": payment_intent_id,
            "status": "succeeded",
            "createdAt": firestore.SERVER_TIMESTAMP,
        })

        if payment_type == "paid_access" and performance_id:
            perf_ref = db.collection("performances").document(performance_id)
            perf_ref.update({
                "paidUsers": firestore.ArrayUnion([user_id]),
            })

        artist_ref = db.collection("users").document(artist_id)
        artist_ref.update({
            "totalEarnings": firestore.Increment(net_amount),
            "pendingPayout": firestore.Increment(net_amount),
        })

        return jsonify({
            "success": True,
            "transactionId": tx_ref.id,
            "netAmount": net_amount,
        })
    except stripe.error.StripeError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@stripe_bp.route("/check-access/<user_id>/<performance_id>", methods=["GET"])
@require_auth
def check_access(user_id, performance_id):
    # Verify the caller is the user they claim to be
    if request.user["uid"] != user_id:
        return jsonify({"error": "Unauthorized"}), 403
    try:
        db = get_firestore_client()
        perf_ref = db.collection("performances").document(performance_id)
        perf_doc = perf_ref.get()

        if not perf_doc.exists:
            return jsonify({"error": "Performance not found"}), 404

        perf_data = perf_doc.to_dict()
        paid_users = perf_data.get("paidUsers", [])

        return jsonify({
            "hasAccess": user_id in paid_users,
            "isPaid": perf_data.get("isPaid", False),
            "price": perf_data.get("ticketPrice", 0),
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@stripe_bp.route("/check-tip-status/<user_id>/<artist_id>", methods=["GET"])
@require_auth
def check_tip_status(user_id, artist_id):
    if request.user["uid"] != user_id:
        return jsonify({"error": "Unauthorized"}), 403
    try:
        db = get_firestore_client()
        txs = (
            db.collection("transactions")
            .where("userId", "==", user_id)
            .where("artistId", "==", artist_id)
            .where("type", "==", "tip")
            .where("status", "==", "succeeded")
            .get()
        )
        tx_list = list(txs)
        if tx_list:
            tx_list.sort(key=lambda t: t.to_dict().get("createdAt", ""), reverse=True)
            return jsonify({"hasTipped": True, "transactionId": tx_list[0].id}), 200
        return jsonify({"hasTipped": False}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@stripe_bp.route("/transaction-history/<artist_id>", methods=["GET"])
def transaction_history(artist_id):
    try:
        db = get_firestore_client()
        txs = (
            db.collection("transactions")
            .where("artistId", "==", artist_id)
            .get()
        )

        transactions = []
        total_gross = 0
        total_fees = 0
        total_net = 0

        for tx in txs:
            tx_data = tx.to_dict()
            created_at = tx_data.get("createdAt")
            if hasattr(created_at, "timestamp"):
                tx_data["createdAt"] = created_at.timestamp()
            transactions.append(tx_data)
            total_gross += tx_data.get("amount", 0)
            total_fees += tx_data.get("platformFee", 0)
            total_net += tx_data.get("netAmount", 0)

        transactions.sort(key=lambda t: t.get("createdAt", ""), reverse=True)

        return jsonify({
            "transactions": transactions,
            "grossEarnings": total_gross,
            "platformFee": total_fees,
            "netEarnings": total_net,
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@stripe_bp.route("/create-checkout-session", methods=["POST"])
def create_checkout_session():
    try:
        data = request.get_json()
        amount = data.get("amount")
        payment_type = data.get("type")
        artist_id = data.get("artistId")
        performance_id = data.get("performanceId")
        user_id = data.get("userId")

        if not amount or not payment_type or not artist_id or not user_id:
            return jsonify({"error": "amount, type, artistId, and userId are required"}), 400

        amount_cents = int(float(amount) * 100)

        platform_fee = int(amount_cents * (settings.PLATFORM_FEE_PERCENT / 100))

        success_url = request.headers.get("Origin", "http://localhost:51311") + "/payment-success?session_id={CHECKOUT_SESSION_ID}"
        cancel_url = request.headers.get("Origin", "http://localhost:51311") + "/payment-cancelled"

        session = stripe.checkout.Session.create(
            payment_method_types=["card"],
            line_items=[{
                "price_data": {
                    "currency": "usd",
                    "product_data": {
                        "name": f"Tip - {payment_type.replace('_', ' ').title()}",
                    },
                    "unit_amount": amount_cents,
                },
                "quantity": 1,
            }],
            mode="payment",
            success_url=success_url,
            cancel_url=cancel_url,
            metadata={
                "type": payment_type,
                "artistId": artist_id,
                "performanceId": performance_id or "",
                "userId": user_id,
            },
        )

        return jsonify({
            "checkoutUrl": session.url,
            "sessionId": session.id,
        })
    except stripe.error.StripeError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@stripe_bp.route("/checkout-complete", methods=["POST"])
def checkout_complete():
    try:
        data = request.get_json()
        session_id = data.get("sessionId")

        if not session_id:
            return jsonify({"error": "sessionId is required"}), 400

        session = stripe.checkout.Session.retrieve(session_id)

        if session.payment_status != "paid":
            return jsonify({"error": "Payment not completed", "status": session.payment_status}), 400

        metadata = session.metadata
        user_id = metadata.get("userId", "")
        artist_id = metadata.get("artistId", "")
        payment_type = metadata.get("type", "")
        performance_id = metadata.get("performanceId", "")
        amount_cents = session.amount_total or 0

        platform_fee = int(amount_cents * (settings.PLATFORM_FEE_PERCENT / 100))
        net_amount = amount_cents - platform_fee

        db = get_firestore_client()
        tx_ref = db.collection("transactions").document()
        tx_ref.set({
            "userId": user_id,
            "artistId": artist_id,
            "amount": amount_cents,
            "platformFee": platform_fee,
            "netAmount": net_amount,
            "type": payment_type,
            "performanceId": performance_id,
            "paymentIntentId": session.payment_intent,
            "status": "succeeded",
            "createdAt": firestore.SERVER_TIMESTAMP,
        })

        if payment_type == "paid_access" and performance_id:
            perf_ref = db.collection("performances").document(performance_id)
            perf_ref.update({
                "paidUsers": firestore.ArrayUnion([user_id]),
            })

        artist_ref = db.collection("users").document(artist_id)
        artist_ref.update({
            "totalEarnings": firestore.Increment(net_amount),
            "pendingPayout": firestore.Increment(net_amount),
        })

        return jsonify({
            "success": True,
            "transactionId": tx_ref.id,
            "netAmount": net_amount,
        })
    except stripe.error.StripeError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@stripe_bp.route("/webhook", methods=["POST"])
def webhook():
    payload = request.get_data()
    sig_header = request.headers.get("Stripe-Signature")

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
        )
    except ValueError:
        return "Invalid payload", 400
    except stripe.error.SignatureVerificationError:
        return "Invalid signature", 400

    db = get_firestore_client()

    if event["type"] == "checkout.session.completed":
        try:
            session = _stripe_to_dict(event["data"]["object"])
            metadata = session.get("metadata", {}) or {}
            user_id = metadata.get("userId", "")
            artist_id = metadata.get("artistId", "")
            payment_type = metadata.get("type", "")
            performance_id = metadata.get("performanceId", "")
            amount_cents = session.get("amount_total", 0) or 0

            pi_raw = session.get("payment_intent")
            payment_intent_id = pi_raw if isinstance(pi_raw, str) else ""
            print(f"[Webhook] checkout.session.completed: user={user_id} artist={artist_id} type={payment_type} amount={amount_cents} pi={payment_intent_id}")

            # Skip if transaction already exists (created by success redirect)
            if payment_intent_id:
                existing = (
                    db.collection("transactions")
                    .where("paymentIntentId", "==", payment_intent_id)
                    .limit(1)
                    .get()
                )
                if list(existing):
                    return jsonify({"status": "ok"}), 200

            platform_fee = int(amount_cents * (settings.PLATFORM_FEE_PERCENT / 100))
            net_amount = amount_cents - platform_fee

            tx_ref = db.collection("transactions").document()
            tx_ref.set({
                "userId": user_id,
                "artistId": artist_id,
                "amount": amount_cents,
                "platformFee": platform_fee,
                "netAmount": net_amount,
                "type": payment_type,
                "performanceId": performance_id,
                "paymentIntentId": payment_intent_id,
                "status": "succeeded",
                "createdAt": firestore.SERVER_TIMESTAMP,
            })

            if payment_type == "paid_access" and performance_id:
                perf_ref = db.collection("performances").document(performance_id)
                perf_ref.update({
                    "paidUsers": firestore.ArrayUnion([user_id]),
                })

            artist_ref = db.collection("users").document(artist_id)
            artist_ref.update({
                "totalEarnings": firestore.Increment(net_amount),
                "pendingPayout": firestore.Increment(net_amount),
            })
        except Exception as e:
            print(f"[Webhook] checkout.session.completed error: {e}")
            traceback.print_exc()

    elif event["type"] == "payment_intent.succeeded":
        try:
            intent = _stripe_to_dict(event["data"]["object"])
            intent_id = intent.get("id", "")
            metadata = intent.get("metadata", {}) or {}
            print(f"[Webhook] payment_intent.succeeded: pi={intent_id} metadata={metadata}")

            txs = (
                db.collection("transactions")
                .where("paymentIntentId", "==", intent_id)
                .limit(1)
                .get()
            )
            tx_list = list(txs)
            if tx_list:
                # Transaction already exists (created by checkout.session.completed)
                # Just make sure the status is up to date.
                tx_list[0].reference.update({"status": "succeeded"})
            else:
                # Native payment intent flow — no checkout session, so the
                # transaction hasn't been written yet. Write it now.
                user_id = metadata.get("userId", "")
                artist_id = metadata.get("artistId", "")
                payment_type = metadata.get("type", "")
                performance_id = metadata.get("performanceId", "")
                amount_cents = intent.get("amount", 0) or 0

                platform_fee = int(amount_cents * (settings.PLATFORM_FEE_PERCENT / 100))
                net_amount = amount_cents - platform_fee

                tx_ref = db.collection("transactions").document()
                tx_ref.set({
                    "userId": user_id,
                    "artistId": artist_id,
                    "amount": amount_cents,
                    "platformFee": platform_fee,
                    "netAmount": net_amount,
                    "type": payment_type,
                    "performanceId": performance_id,
                    "paymentIntentId": intent_id,
                    "status": "succeeded",
                    "createdAt": firestore.SERVER_TIMESTAMP,
                })

                if payment_type == "paid_access" and performance_id:
                    perf_ref = db.collection("performances").document(performance_id)
                    perf_ref.update({
                        "paidUsers": firestore.ArrayUnion([user_id]),
                    })

                if artist_id:
                    artist_ref = db.collection("users").document(artist_id)
                    artist_ref.update({
                        "totalEarnings": firestore.Increment(net_amount),
                        "pendingPayout": firestore.Increment(net_amount),
                    })
        except Exception as e:
            print(f"[Webhook] payment_intent.succeeded error: {e}")
            traceback.print_exc()

    elif event["type"] == "payment_intent.payment_failed":
        try:
            intent = _stripe_to_dict(event["data"]["object"])
            intent_id = intent.get("id", "")
            print(f"[Webhook] payment_intent.payment_failed: pi={intent_id}")
            txs = (
                db.collection("transactions")
                .where("paymentIntentId", "==", intent_id)
                .limit(1)
                .get()
            )
            for tx in txs:
                tx.reference.update({"status": "failed"})
        except Exception as e:
            print(f"[Webhook] payment_intent.payment_failed error: {e}")
            traceback.print_exc()

    return jsonify({"status": "ok"}), 200
