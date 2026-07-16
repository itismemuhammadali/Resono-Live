from functools import wraps
from flask import request, jsonify
from firebase_config import verify_firebase_token


def require_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get("Authorization", "")
        if not auth_header.startswith("Bearer "):
            return jsonify({"detail": "No authorization token provided"}), 401

        token = auth_header.split(" ", 1)[1]
        try:
            decoded = verify_firebase_token(token)
            request.user = {
                "uid": decoded["uid"],
                "email": decoded.get("email", ""),
                "name": decoded.get("name", ""),
            }
        except Exception:
            return jsonify({"detail": "Invalid or expired token"}), 401

        return f(*args, **kwargs)
    return decorated
