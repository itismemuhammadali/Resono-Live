from flask import Blueprint, request, jsonify
from middleware import require_auth
from services.firestore import db

notifications_bp = Blueprint("notifications", __name__, url_prefix="/notifications")


@notifications_bp.route("", methods=["GET"])
@require_auth
def get_notifications():
    uid = request.user["uid"]
    limit = request.args.get("limit", 20, type=int)
    notifications = db.get_notifications(uid, limit=limit)
    return jsonify(notifications)


@notifications_bp.route("/<notification_id>/read", methods=["PUT"])
@require_auth
def mark_read(notification_id):
    uid = request.user["uid"]
    success = db.mark_notification_read(uid, notification_id)
    if not success:
        return jsonify({"detail": "Notification not found"}), 404
    return jsonify({"read": True})
