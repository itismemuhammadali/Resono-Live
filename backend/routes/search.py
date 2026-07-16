from flask import Blueprint, request, jsonify
from services.firestore import db

search_bp = Blueprint("search", __name__, url_prefix="/search")


@search_bp.route("/users", methods=["GET"])
def search_users():
    q = request.args.get("q", "")
    genre = request.args.get("genre")
    limit = request.args.get("limit", 20, type=int)
    results = db.search_users(q, genre=genre, limit=limit)
    return jsonify({"users": results})


@search_bp.route("/posts", methods=["GET"])
def search_posts():
    q = request.args.get("q", "")
    genre = request.args.get("genre")
    limit = request.args.get("limit", 20, type=int)
    results = db.search_posts(q, genre=genre, limit=limit)
    return jsonify({"posts": results})


@search_bp.route("/trending-genres", methods=["GET"])
def trending_genres():
    limit = request.args.get("limit", 10, type=int)
    genres = db.get_trending_genres(limit=limit)
    return jsonify({"genres": genres})


@search_bp.route("/trending-artists", methods=["GET"])
def trending_artists():
    limit = request.args.get("limit", 10, type=int)
    artists = db.get_trending_artists(limit=limit)
    return jsonify({"artists": artists})
