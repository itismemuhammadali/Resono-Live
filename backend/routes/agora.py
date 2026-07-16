import os
import time
from flask import Blueprint, request, jsonify
from agora_token_builder import RtcTokenBuilder
from middleware import require_auth
from firebase_config import get_firestore_client

agora_bp = Blueprint("agora", __name__, url_prefix="/agora")

AGORA_APP_ID = os.getenv("AGORA_APP_ID", "")
AGORA_APP_CERTIFICATE = os.getenv("AGORA_APP_CERTIFICATE", "")


@agora_bp.route("/token", methods=["POST"])
@require_auth
def generate_token():
    body = request.get_json(force=True)
    channel_name = body.get("channelName", "live-stream-test")
    uid = body.get("uid", 0)
    role = body.get("role", "publisher")
    expire_time = body.get("expireTime", 3600)

    if not AGORA_APP_ID or not AGORA_APP_CERTIFICATE:
        return jsonify({"error": "Agora credentials not configured"}), 500

    # For audience role, verify payment access if the performance is paid
    if role == "subscriber":
        performance_id = body.get("performanceId")
        if performance_id:
            db = get_firestore_client()
            perf_doc = db.collection("performances").document(performance_id).get()
            if perf_doc.exists:
                perf_data = perf_doc.to_dict()
                if perf_data.get("isPaid", False):
                    paid_users = perf_data.get("paidUsers", [])
                    firebase_uid = request.user["uid"]
                    if firebase_uid not in paid_users:
                        return jsonify({"error": "Payment required to access this stream"}), 403

    # role: 1 = publisher (broadcaster), 2 = subscriber (audience)
    agora_role = 1 if role == "publisher" else 2
    # privilegeExpiredTs: absolute timestamp (seconds since epoch)
    privilege_expiration = int(time.time()) + expire_time

    token = RtcTokenBuilder.buildTokenWithUid(
        AGORA_APP_ID,
        AGORA_APP_CERTIFICATE,
        channel_name,
        uid,
        agora_role,
        privilege_expiration,
    )

    return jsonify({
        "token": token,
        "channelName": channel_name,
        "uid": uid,
        "expiresIn": expire_time,
    })
