import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { sendNotification } from "./notifications";

// Initialize if not already done
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// Load Stripe credentials from Firebase Environment Configuration
// Set via: firebase functions:secrets:set STRIPE_SECRET_KEY
// Set via: firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
const STRIPE_SECRET_KEY = process.env.STRIPE_SECRET_KEY || "";
const STRIPE_WEBHOOK_SECRET = process.env.STRIPE_WEBHOOK_SECRET || "";
const PLATFORM_FEE_PERCENT = 15;

// Initialize Stripe SDK
const stripe = require("stripe")(STRIPE_SECRET_KEY);

// ─────────────────────────────────────────────────────────────
// stripeWebhook — HTTP Function (raw body for signature verification)
// ─────────────────────────────────────────────────────────────

/**
 * stripeWebhook — onRequest Function
 *
 * Handles Stripe webhook events securely.
 * Stripe requires the raw body for signature verification.
 *
 * Configure in Stripe Dashboard:
 *   Endpoint: https://<region>-<project>.cloudfunctions.net/stripeWebhook
 *   Events: checkout.session.completed, payment_intent.succeeded, payment_intent.payment_failed
 */
export const stripeWebhook = functions
  .runWith({
    secrets: ["STRIPE_SECRET_KEY", "STRIPE_WEBHOOK_SECRET"],
  })
  .https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }

  const sigHeader = req.headers["stripe-signature"];
  if (!sigHeader || typeof sigHeader !== "string") {
    res.status(400).send("Missing Stripe-Signature header");
    return;
  }

  let event;
  try {
    event = stripe.webhooks.constructEvent(
      req.rawBody,
      sigHeader,
      STRIPE_WEBHOOK_SECRET
    );
  } catch (err: any) {
    functions.logger.error(`Webhook signature verification failed: ${err.message}`);
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }

  // Handle events
  try {
    switch (event.type) {
      case "checkout.session.completed":
        await handleCheckoutSessionCompleted(event.data.object);
        break;

      case "payment_intent.succeeded":
        await handlePaymentIntentSucceeded(event.data.object);
        break;

      case "payment_intent.payment_failed":
        await handlePaymentIntentFailed(event.data.object);
        break;

      default:
        functions.logger.info(`Unhandled event type: ${event.type}`);
    }
  } catch (err: any) {
    functions.logger.error(`Error handling ${event.type}: ${err.message}`);
  }

  res.status(200).json({ status: "ok" });
});

// ─────────────────────────────────────────────────────────────
// Event Handlers
// ─────────────────────────────────────────────────────────────

async function handleCheckoutSessionCompleted(session: any) {
  const metadata = session.metadata || {};
  const userId = metadata.userId || "";
  const artistId = metadata.artistId || "";
  const paymentType = metadata.type || "";
  const performanceId = metadata.performanceId || "";
  const amountCents = session.amount_total || 0;
  const paymentIntentId =
    typeof session.payment_intent === "string" ? session.payment_intent : "";

  functions.logger.info(
    `checkout.session.completed: user=${userId} artist=${artistId} type=${paymentType} amount=${amountCents}`
  );

  // Skip if transaction already exists (created by success redirect)
  if (paymentIntentId) {
    const existing = await db
      .collection("transactions")
      .where("paymentIntentId", "==", paymentIntentId)
      .limit(1)
      .get();
    if (!existing.empty) {
      functions.logger.info("Transaction already exists, skipping");
      return;
    }
  }

  const platformFee = Math.floor(amountCents * (PLATFORM_FEE_PERCENT / 100));
  const netAmount = amountCents - platformFee;

  // Create transaction record
  const txRef = db.collection("transactions").doc();
  await txRef.set({
    userId,
    artistId,
    amount: amountCents,
    platformFee,
    netAmount,
    type: paymentType,
    performanceId,
    paymentIntentId,
    status: "succeeded",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Grant paid access to performance
  if (paymentType === "paid_access" && performanceId) {
    await db.collection("performances").doc(performanceId).update({
      paidUsers: admin.firestore.FieldValue.arrayUnion(userId),
    });
  }

  // Update artist earnings
  if (artistId) {
    await db.collection("users").doc(artistId).update({
      totalEarnings: admin.firestore.FieldValue.increment(netAmount),
      pendingPayout: admin.firestore.FieldValue.increment(netAmount),
    });
  }

  // Send payment notification to listener
  const amountDollars = (amountCents / 100).toFixed(2);
  await sendNotification(userId, {
    type: "payment_confirmed",
    title: "Payment Confirmed",
    body: `Your ${paymentType === "tip" ? "tip" : "access payment"} of $${amountDollars} was confirmed`,
    data: { performanceId, artistId, type: paymentType },
  });

  // Send tip received notification to artist
  if (paymentType === "tip" && artistId) {
    await sendNotification(artistId, {
      type: "tip_received",
      title: "Tip Received",
      body: `You received a $${amountDollars} tip`,
      data: { userId, performanceId },
    });
  }

  functions.logger.info(`Transaction created: ${txRef.id}`);
}

async function handlePaymentIntentSucceeded(intent: any) {
  const intentId = intent.id;
  const metadata = intent.metadata || {};

  functions.logger.info(`payment_intent.succeeded: pi=${intentId}`);

  // Check if transaction already exists
  const existing = await db
    .collection("transactions")
    .where("paymentIntentId", "==", intentId)
    .limit(1)
    .get();

  if (!existing.empty) {
    // Transaction exists — just update status
    await existing.docs[0].ref.update({ status: "succeeded" });
    functions.logger.info("Transaction status updated to succeeded");
    return;
  }

  // Native payment intent flow — create transaction now
  const userId = metadata.userId || "";
  const artistId = metadata.artistId || "";
  const paymentType = metadata.type || "";
  const performanceId = metadata.performanceId || "";
  const amountCents = intent.amount || 0;

  const platformFee = Math.floor(amountCents * (PLATFORM_FEE_PERCENT / 100));
  const netAmount = amountCents - platformFee;

  const txRef = db.collection("transactions").doc();
  await txRef.set({
    userId,
    artistId,
    amount: amountCents,
    platformFee,
    netAmount,
    type: paymentType,
    performanceId,
    paymentIntentId: intentId,
    status: "succeeded",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Grant paid access
  if (paymentType === "paid_access" && performanceId) {
    await db.collection("performances").doc(performanceId).update({
      paidUsers: admin.firestore.FieldValue.arrayUnion(userId),
    });
  }

  // Update artist earnings
  if (artistId) {
    await db.collection("users").doc(artistId).update({
      totalEarnings: admin.firestore.FieldValue.increment(netAmount),
      pendingPayout: admin.firestore.FieldValue.increment(netAmount),
    });
  }

  // Send payment notification to listener (native payment flow)
  const amountDollars = (amountCents / 100).toFixed(2);
  await sendNotification(userId, {
    type: "payment_confirmed",
    title: "Payment Confirmed",
    body: `Your ${paymentType === "tip" ? "tip" : "access payment"} of $${amountDollars} was confirmed`,
    data: { performanceId, artistId, type: paymentType },
  });

  // Send tip received notification to artist
  if (paymentType === "tip" && artistId) {
    await sendNotification(artistId, {
      type: "tip_received",
      title: "Tip Received",
      body: `You received a $${amountDollars} tip`,
      data: { userId, performanceId },
    });
  }

  functions.logger.info(`Transaction created: ${txRef.id}`);
}

async function handlePaymentIntentFailed(intent: any) {
  const intentId = intent.id;
  functions.logger.info(`payment_intent.payment_failed: pi=${intentId}`);

  const txs = await db
    .collection("transactions")
    .where("paymentIntentId", "==", intentId)
    .limit(1)
    .get();

  for (const tx of txs.docs) {
    await tx.ref.update({ status: "failed" });

    // Send payment failed notification to user
    const txData = tx.data();
    if (txData.userId) {
      await sendNotification(txData.userId, {
        type: "payment_failed",
        title: "Payment Failed",
        body: "Your payment could not be processed. Please try again.",
        data: {
          performanceId: txData.performanceId || "",
          artistId: txData.artistId || "",
        },
      });
    }
  }
}

// ─────────────────────────────────────────────────────────────
// createPaymentIntent — HTTPS Callable Function
// ─────────────────────────────────────────────────────────────

/**
 * createPaymentIntent — onCall Function
 *
 * Creates a Stripe PaymentIntent for native mobile payments.
 * Requires Firebase Authentication.
 *
 * Input:
 *   amount: number — Amount in dollars (e.g., 5.00)
 *   type: string — "tip" or "paid_access"
 *   artistId: string — Artist receiving payment
 *   performanceId?: string — Performance for paid_access
 *
 * Returns:
 *   { clientSecret, paymentIntentId }
 */
export const createPaymentIntent = functions
  .runWith({
    secrets: ["STRIPE_SECRET_KEY"],
  })
  .https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated."
    );
  }

  const { amount, type, artistId, performanceId } = data;

  if (!amount || !type || !artistId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "amount, type, and artistId are required."
    );
  }

  if (type !== "tip" && type !== "paid_access") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "type must be 'tip' or 'paid_access'."
    );
  }

  const amountCents = Math.floor(parseFloat(amount) * 100);
  const userId = context.auth.uid;

  try {
    const intent = await stripe.paymentIntents.create({
      amount: amountCents,
      currency: "usd",
      automatic_payment_methods: { enabled: true },
      metadata: {
        type,
        artistId,
        performanceId: performanceId || "",
        userId,
      },
    });

    return {
      clientSecret: intent.client_secret,
      paymentIntentId: intent.id,
    };
  } catch (err: any) {
    throw new functions.https.HttpsError("internal", err.message);
  }
});

// ─────────────────────────────────────────────────────────────
// createCheckoutSession — HTTPS Callable Function
// ─────────────────────────────────────────────────────────────

/**
 * createCheckoutSession — onCall Function
 *
 * Creates a Stripe Checkout Session for web payments.
 * Requires Firebase Authentication.
 *
 * Input:
 *   amount: number — Amount in dollars
 *   type: string — "tip" or "paid_access"
 *   artistId: string — Artist receiving payment
 *   performanceId?: string — Performance for paid_access
 *
 * Returns:
 *   { checkoutUrl, sessionId }
 */
export const createCheckoutSession = functions
  .runWith({
    secrets: ["STRIPE_SECRET_KEY"],
  })
  .https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated."
    );
  }

  const { amount, type, artistId, performanceId } = data;

  if (!amount || !type || !artistId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "amount, type, and artistId are required."
    );
  }

  const amountCents = Math.floor(parseFloat(amount) * 100);
  const userId = context.auth.uid;

  // Build success/cancel URLs using the Cloud Function's own region
  const region = process.env.FUNCTION_REGION || "us-central1";
  const projectId = process.env.GCLOUD_PROJECT || "";
  const baseUrl = `https://${region}-${projectId}.cloudfunctions.net`;
  const successUrl = `${baseUrl}/paymentSuccess?session_id={CHECKOUT_SESSION_ID}`;
  const cancelUrl = `${baseUrl}/paymentCancelled`;

  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      line_items: [
        {
          price_data: {
            currency: "usd",
            product_data: {
              name: `Tip - ${type.replace(/_/g, " ").replace(/\b\w/g, (c: string) => c.toUpperCase())}`,
            },
            unit_amount: amountCents,
          },
          quantity: 1,
        },
      ],
      mode: "payment",
      success_url: successUrl,
      cancel_url: cancelUrl,
      metadata: {
        type,
        artistId,
        performanceId: performanceId || "",
        userId,
      },
    });

    return {
      checkoutUrl: session.url,
      sessionId: session.id,
    };
  } catch (err: any) {
    throw new functions.https.HttpsError("internal", err.message);
  }
});

// ─────────────────────────────────────────────────────────────
// checkAccess — HTTPS Callable Function
// ─────────────────────────────────────────────────────────────

/**
 * checkAccess — onCall Function
 *
 * Checks if a user has paid access to a performance.
 * Requires Firebase Authentication.
 *
 * Input:
 *   userId: string — User ID to check
 *   performanceId: string — Performance ID
 *
 * Returns:
 *   { hasAccess: boolean, isPaid: boolean, price: number }
 */
export const checkAccess = functions
  .runWith({
    secrets: ["STRIPE_SECRET_KEY"],
  })
  .https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated."
    );
  }

  const { userId, performanceId } = data;

  if (!userId || !performanceId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "userId and performanceId are required."
    );
  }

  try {
    const perfDoc = await db
      .collection("performances")
      .doc(performanceId)
      .get();

    if (!perfDoc.exists) {
      return {
        hasAccess: false,
        isPaid: false,
        price: 0,
      };
    }

    const perfData = perfDoc.data()!;
    const isPaid = perfData.isPaid === true;

    if (!isPaid) {
      // Free performance — everyone has access
      return {
        hasAccess: true,
        isPaid: false,
        price: 0,
      };
    }

    // Paid performance — check if user is in paidUsers array
    const paidUsers = perfData.paidUsers || [];
    const hasAccess = paidUsers.includes(userId);

    return {
      hasAccess,
      isPaid: true,
      price: perfData.price || 9.99,
    };
  } catch (err: any) {
    throw new functions.https.HttpsError("internal", err.message);
  }
});

// ─────────────────────────────────────────────────────────────
// checkTipStatus — HTTPS Callable Function
// ─────────────────────────────────────────────────────────────

/**
 * checkTipStatus — onCall Function
 *
 * Checks if a user has tipped an artist.
 * Requires Firebase Authentication.
 *
 * Input:
 *   userId: string — User ID
 *   artistId: string — Artist ID
 *
 * Returns:
 *   { hasTipped: boolean, tipAmount: number }
 */
export const checkTipStatus = functions
  .runWith({
    secrets: ["STRIPE_SECRET_KEY"],
  })
  .https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated."
    );
  }

  const { userId, artistId } = data;

  if (!userId || !artistId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "userId and artistId are required."
    );
  }

  try {
    const tips = await db
      .collection("transactions")
      .where("userId", "==", userId)
      .where("artistId", "==", artistId)
      .where("type", "==", "tip")
      .where("status", "==", "succeeded")
      .get();

    const hasTipped = !tips.empty;
    const tipAmount = tips.docs.reduce(
      (sum, doc) => sum + (doc.data().amount || 0),
      0
    );

    return {
      hasTipped,
      tipAmount: tipAmount / 100, // Convert from cents to dollars
    };
  } catch (err: any) {
    throw new functions.https.HttpsError("internal", err.message);
  }
});

// ─────────────────────────────────────────────────────────────
// getTransactionHistory — HTTPS Callable Function
// ─────────────────────────────────────────────────────────────

/**
 * getTransactionHistory — onCall Function
 *
 * Retrieves transaction history for an artist.
 * Requires Firebase Authentication.
 *
 * Input:
 *   artistId: string — Artist ID to get transactions for
 *
 * Returns:
 *   { transactions: Transaction[], totalEarnings: number }
 */
export const getTransactionHistory = functions
  .runWith({
    secrets: ["STRIPE_SECRET_KEY"],
  })
  .https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated."
    );
  }

  const { artistId } = data;

  if (!artistId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "artistId is required."
    );
  }

  try {
    const transactions = await db
      .collection("transactions")
      .where("artistId", "==", artistId)
      .orderBy("createdAt", "desc")
      .limit(100)
      .get();

    const txList = transactions.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    const totalEarnings = txList.reduce(
      (sum: number, tx: any) => sum + (tx.netAmount || 0),
      0
    );

    return {
      transactions: txList,
      totalEarnings,
    };
  } catch (err: any) {
    throw new functions.https.HttpsError("internal", err.message);
  }
});
