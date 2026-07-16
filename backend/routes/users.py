from flask import Blueprint, request, jsonify
from middleware import require_auth
from services.firestore import db

users_bp = Blueprint("users", __name__, url_prefix="/users")


@users_bp.route("/me", methods=["POST"])
@require_auth
def create_my_profile():
    uid = request.user["uid"]
    body = request.get_json(force=True)
    created = db.create_user(uid, body)
    return jsonify(created), 201


@users_bp.route("/me", methods=["GET"])
@require_auth
def get_my_profile():
    uid = request.user["uid"]
    profile = db.get_user(uid)
    if not profile:
        return jsonify({"detail": "User not found"}), 404
    return jsonify(profile)


@users_bp.route("/<target_uid>", methods=["GET"])
def get_user_profile(target_uid):
    profile = db.get_user(target_uid)
    if not profile:
        return jsonify({"detail": "User not found"}), 404
    if not profile.get("isPublicProfile", True):
        return jsonify({"detail": "Profile is private"}), 403
    return jsonify(profile)


@users_bp.route("/me", methods=["PUT"])
@require_auth
def update_my_profile():
    uid = request.user["uid"]
    body = request.get_json(force=True)
    if not body:
        return jsonify({"detail": "No fields to update"}), 400
    updated = db.update_user(uid, body)
    return jsonify(updated)


@users_bp.route("/me/artist-profile", methods=["POST"])
@require_auth
def save_artist_profile():
    uid = request.user["uid"]
    body = request.get_json(force=True)
    updated = db.save_artist_profile(uid, body)
    return jsonify(updated)


@users_bp.route("/me/listener-profile", methods=["POST"])
@require_auth
def save_listener_profile():
    uid = request.user["uid"]
    body = request.get_json(force=True)
    updated = db.save_listener_profile(uid, body)
    return jsonify(updated)


@users_bp.route("/me/role", methods=["GET"])
@require_auth
def get_my_role():
    uid = request.user["uid"]
    role = db.get_user_role(uid)
    if not role:
        return jsonify({"detail": "Role not set"}), 404
    return jsonify({"role": role})


@users_bp.route("/<target_uid>/follow", methods=["POST"])
@require_auth
def toggle_follow(target_uid):
    uid = request.user["uid"]
    result = db.follow_artist(uid, target_uid)
    return jsonify(result)


@users_bp.route("/<target_uid>/follow-state", methods=["GET"])
@require_auth
def get_follow_state(target_uid):
    uid = request.user["uid"]
    is_following = db.is_following(uid, target_uid)
    followers_count = db.get_followers_count(target_uid)
    return jsonify({"isFollowing": is_following, "followersCount": followers_count})


@users_bp.route("/me/library-stats", methods=["GET"])
@require_auth
def get_my_library_stats():
    uid = request.user["uid"]
    stats = db.get_user_library_stats(uid)
    return jsonify(stats)


@users_bp.route("/me/saved-songs", methods=["GET"])
@require_auth
def get_my_saved_songs():
    uid = request.user["uid"]
    songs = db.get_saved_songs(uid)
    return jsonify({"songs": songs})


@users_bp.route("/me/history", methods=["GET"])
@require_auth
def get_my_history():
    uid = request.user["uid"]
    history = db.get_listening_history(uid)
    return jsonify({"history": history})
