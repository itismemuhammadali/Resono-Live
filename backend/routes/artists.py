from flask import Blueprint, request, jsonify
from middleware import require_auth
from services.firestore import db

artists_bp = Blueprint("artists", __name__, url_prefix="/artists")


@artists_bp.route("/me/stats", methods=["GET"])
@require_auth
def get_my_stats():
    uid = request.user["uid"]
    stats = db.get_artist_stats(uid)
    return jsonify(stats)


@artists_bp.route("/me/analytics", methods=["GET"])
@require_auth
def get_my_analytics():
    uid = request.user["uid"]
    analytics = db.get_artist_analytics(uid)
    return jsonify(analytics)


@artists_bp.route("/me/posts/<post_id>/play", methods=["POST"])
@require_auth
def record_play(post_id):
    db.increment_post_plays(post_id)
    return jsonify({"played": True})
