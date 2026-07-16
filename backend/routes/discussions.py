from flask import Blueprint, request, jsonify
from middleware import require_auth
from services.firestore import db

discussions_bp = Blueprint("discussions", __name__, url_prefix="/discussions")


@discussions_bp.route("", methods=["POST"])
@require_auth
def create_discussion():
    uid = request.user["uid"]
    body = request.get_json(force=True)
    discussion = db.create_discussion(uid, body)
    return jsonify(discussion), 201


@discussions_bp.route("", methods=["GET"])
def get_discussions():
    limit = request.args.get("limit", 20, type=int)
    start_after = request.args.get("startAfter")
    discussions = db.get_discussions(limit=limit, start_after=start_after)
    return jsonify(discussions)


@discussions_bp.route("/<discussion_id>/replies", methods=["GET"])
def get_replies(discussion_id):
    limit = request.args.get("limit", 20, type=int)
    replies = db.get_replies(discussion_id, limit=limit)
    return jsonify(replies)


@discussions_bp.route("/<discussion_id>/replies", methods=["POST"])
@require_auth
def create_reply(discussion_id):
    uid = request.user["uid"]
    body = request.get_json(force=True)
    reply = db.create_reply(discussion_id, uid, body["text"])
    return jsonify(reply), 201
