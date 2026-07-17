from flask import Blueprint, request, jsonify
from middleware import require_auth
from services.firestore import db

performances_bp = Blueprint("performances", __name__, url_prefix="/performances")


@performances_bp.route("", methods=["POST"])
@require_auth
def create_performance():
    uid = request.user["uid"]
    body = request.get_json(force=True)
    performance = db.create_performance(uid, body)
    return jsonify(performance), 201


@performances_bp.route("", methods=["GET"])
def get_performances():
    limit = request.args.get("limit", 20, type=int)
    status = request.args.get("status")
    artist_id = request.args.get("artist_id")
    performances = db.get_performances(limit=limit, status=status, artist_id=artist_id)
    return jsonify({"performances": performances})


@performances_bp.route("/<performance_id>", methods=["PUT"])
@require_auth
def update_performance(performance_id):
    uid = request.user["uid"]
    body = request.get_json(force=True)
    updated = db.update_performance(performance_id, uid, body)
    if not updated:
        return jsonify({"detail": "Not found or unauthorized"}), 404
    return jsonify(updated)


@performances_bp.route("/<performance_id>", methods=["DELETE"])
@require_auth
def delete_performance(performance_id):
    uid = request.user["uid"]
    deleted = db.delete_performance(performance_id, uid)
    if not deleted:
        return jsonify({"detail": "Not found or unauthorized"}), 403
    return jsonify({"deleted": True})


@performances_bp.route("/<performance_id>/join", methods=["POST"])
@require_auth
def join_performance(performance_id):
    uid = request.user["uid"]
    # Check payment access before allowing join
    perf_doc = db._performances.document(performance_id).get()
    if perf_doc.exists:
        perf_data = perf_doc.to_dict()
        if perf_data.get("isPaid", False):
            paid_users = perf_data.get("paidUsers", [])
            if uid not in paid_users:
                return jsonify({"error": "Payment required to join this performance"}), 403
    result = db.join_performance(performance_id, uid)
    return jsonify(result)


@performances_bp.route("/<performance_id>/leave", methods=["POST"])
@require_auth
def leave_performance(performance_id):
    uid = request.user["uid"]
    result = db.leave_performance(performance_id, uid)
    return jsonify(result)



@performances_bp.route("/<performance_id>/like", methods=["POST"])
@require_auth
def like_performance(performance_id):
    uid = request.user["uid"]
    result = db.like_performance(performance_id, uid)
    return jsonify(result)


@performances_bp.route("/<performance_id>/save", methods=["POST"])
@require_auth
def save_performance(performance_id):
    uid = request.user["uid"]
    result = db.save_performance(performance_id, uid)
    return jsonify(result)


@performances_bp.route("/<performance_id>/view", methods=["POST"])
@require_auth
def record_view(performance_id):
    uid = request.user["uid"]
    result = db.record_performance_view(performance_id, uid)
    return jsonify(result)


@performances_bp.route("/<performance_id>/state", methods=["GET"])
@require_auth
def get_performance_state(performance_id):
    uid = request.user["uid"]
    state = db.get_performance_user_state(performance_id, uid)
    return jsonify(state)
