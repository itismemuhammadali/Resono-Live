from flask import Blueprint, request, jsonify
from middleware import require_auth
from services.firestore import db

posts_bp = Blueprint("posts", __name__, url_prefix="/posts")


@posts_bp.route("", methods=["POST"])
@require_auth
def create_post():
    uid = request.user["uid"]
    body = request.get_json(force=True)
    post = db.create_post(uid, body)
    return jsonify(post), 201


@posts_bp.route("/feed", methods=["GET"])
def get_feed():
    limit = request.args.get("limit", 20, type=int)
    start_after = request.args.get("startAfter")
    posts = db.get_feed(limit=limit, start_after=start_after)
    return jsonify(posts)


@posts_bp.route("/<post_id>", methods=["GET"])
def get_post(post_id):
    post = db.get_post(post_id)
    if not post:
        return jsonify({"detail": "Post not found"}), 404
    return jsonify(post)


@posts_bp.route("/<post_id>", methods=["DELETE"])
@require_auth
def delete_post(post_id):
    uid = request.user["uid"]
    deleted = db.delete_post(post_id, uid)
    if not deleted:
        return jsonify({"detail": "Cannot delete post"}), 403
    return jsonify({"deleted": True})


@posts_bp.route("/<post_id>/like", methods=["POST"])
@require_auth
def like_post(post_id):
    uid = request.user["uid"]
    result = db.like_post(post_id, uid)
    return jsonify(result)


@posts_bp.route("/<post_id>/swipe", methods=["POST"])
@require_auth
def swipe_post(post_id):
    uid = request.user["uid"]
    body = request.get_json(force=True)
    result = db.record_swipe(uid, post_id, body.get("liked", False))
    return jsonify(result)


@posts_bp.route("/<post_id>/comments", methods=["GET"])
def get_comments(post_id):
    limit = request.args.get("limit", 20, type=int)
    comments = db.get_comments(post_id, limit=limit)
    return jsonify(comments)


@posts_bp.route("/<post_id>/comments", methods=["POST"])
@require_auth
def create_comment(post_id):
    uid = request.user["uid"]
    body = request.get_json(force=True)
    comment = db.create_comment(post_id, uid, body["text"])
    return jsonify(comment), 201
