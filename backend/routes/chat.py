from flask import Blueprint, request, jsonify
from middleware import require_auth
from services.firestore import db

chat_bp = Blueprint("chat", __name__, url_prefix="/chat")


@chat_bp.route("", methods=["POST"])
@require_auth
def get_or_create_chat():
    uid = request.user["uid"]
    body = request.get_json(force=True)
    chat = db.get_or_create_chat(uid, body["receiverId"])
    return jsonify(chat)


@chat_bp.route("/<other_uid>/messages", methods=["GET"])
@require_auth
def get_messages(other_uid):
    uid = request.user["uid"]
    limit = request.args.get("limit", 50, type=int)
    messages = db.get_chat_messages(uid, other_uid, limit=limit)
    return jsonify(messages)


@chat_bp.route("/<other_uid>/messages", methods=["POST"])
@require_auth
def send_message(other_uid):
    uid = request.user["uid"]
    body = request.get_json(force=True)
    message = db.send_chat_message(uid, other_uid, body["text"])
    return jsonify(message), 201


@chat_bp.route("/chats", methods=["GET"])
@require_auth
def get_user_chats():
    uid = request.user["uid"]
    chats = db.get_user_chats(uid)
    return jsonify(chats)
