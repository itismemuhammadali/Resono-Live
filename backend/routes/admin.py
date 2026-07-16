import csv
import io
from datetime import datetime, timezone
from flask import Blueprint, request, jsonify, Response
from firebase_config import get_firestore_client
from firebase_admin import firestore
from middleware import require_auth
from services.firestore import _now

admin_bp = Blueprint("admin", __name__, url_prefix="/admin")


def _get_db():
    return get_firestore_client()


def _require_admin():
    db = _get_db()
    uid = request.user["uid"]
    doc = db.collection("users").document(uid).get()
    if not doc.exists:
        return False
    role = doc.to_dict().get("role", "")
    return role in ("admin", "superadmin")


def _resolve_artist_name(db, uid):
    if not uid:
        return ""
    doc = db.collection("users").document(uid).get()
    if doc.exists:
        d = doc.to_dict()
        return d.get("artistName") or d.get("name", uid)
    return uid


def _format_date(dt) -> str:
    if not dt:
        return ""
    if hasattr(dt, "strftime"):
        return dt.strftime("%b %d, %Y")
    if isinstance(dt, (int, float)):
        if dt > 1e12:
            dt = dt / 1000
        return datetime.fromtimestamp(dt, tz=timezone.utc).strftime("%b %d, %Y")
    s = str(dt)
    if "T" in s:
        s = s.split("T")[0]
    return s


def _user_to_artist(doc, db=None) -> dict:
    d = doc.to_dict()
    song_count = 0
    if db:
        song_count = len(list(db.collection("performances").where("artist_id", "==", doc.id).stream()))
    return {
        "id": doc.id,
        "name": d.get("name", ""),
        "stageName": d.get("artistName", d.get("name", "")),
        "email": d.get("email", ""),
        "profileImageUrl": d.get("profileImageUrl", ""),
        "genre": (d.get("genres") or [""])[0] if d.get("genres") else "",
        "songs": song_count,
        "followers": d.get("followersCount", 0),
        "verified": d.get("verified", False),
        "status": d.get("status", "Pending"),
        "joined": _format_date(d.get("createdAt")),
    }


def _user_to_listener(doc) -> dict:
    d = doc.to_dict()
    return {
        "id": doc.id,
        "name": d.get("name", ""),
        "username": d.get("username", d.get("name", "")),
        "email": d.get("email", ""),
        "profileImageUrl": d.get("profileImageUrl", ""),
        "genres": d.get("favoriteGenres", []),
        "songs": d.get("likedCount", 0),
        "posts": d.get("postsCount", 0),
        "status": d.get("status", "Active"),
        "lastActive": _format_date(d.get("lastActive") or d.get("updatedAt")),
        "dayStreak": d.get("dayStreak", 0),
    }


def _post_to_community(doc) -> dict:
    d = doc.to_dict()
    return {
        "id": doc.id,
        "title": d.get("title", d.get("caption", "")),
        "author": d.get("authorName", d.get("author_id", "")),
        "replies": d.get("repliesCount", d.get("comments_count", 0)),
        "likes": d.get("likesCount", d.get("likes_count", 0)),
        "status": d.get("status", "Published"),
        "date": _format_date(d.get("createdAt")),
        "category": d.get("category", (d.get("genres") or [""])[0] if d.get("genres") else ""),
        "content": d.get("content", d.get("caption", "")),
    }


def _perf_to_song(doc, artist_names=None) -> dict:
    d = doc.to_dict()
    artist_id = d.get("artist_id", "")
    artist_name = ""
    if artist_names and artist_id in artist_names:
        artist_name = artist_names[artist_id]
    elif artist_id:
        artist_name = artist_id
    reports = d.get("reports_count", 0)
    if reports > 0:
        status = "Reported"
    elif d.get("isFeatured"):
        status = "Featured"
    else:
        status = d.get("status", "Approved")
        if status in ("live", "ended", "upcoming"):
            status = "Approved"
    return {
        "id": doc.id,
        "title": d.get("title", ""),
        "artist": artist_name or d.get("artistName", ""),
        "genre": (d.get("genres") or [""])[0] if d.get("genres") else "",
        "duration": d.get("duration", ""),
        "yes": d.get("likes_count", 0),
        "no": d.get("swipes_no_count", 0),
        "saves": d.get("saves_count", 0),
        "reports": reports,
        "status": status,
        "uploaded": _format_date(d.get("createdAt")),
        "thumbnailUrl": d.get("thumbnailUrl", ""),
        "type": d.get("type", "recorded"),
    }


# ── Analytics ────────────────────────────────────────────────────

@admin_bp.route("/analytics", methods=["GET"])
@require_auth
def get_analytics():
    if not _require_admin():
        return jsonify({"detail": "Forbidden"}), 403

    db = _get_db()

    users = list(db.collection("users").stream())
    total_listeners = sum(1 for u in users if u.to_dict().get("role") == "listener")
    total_artists = sum(1 for u in users if u.to_dict().get("role") == "artist")

    performances = list(db.collection("performances").stream())
    total_performances = len(performances)
    live_sessions = sum(1 for p in performances if p.to_dict().get("status") == "live")

    posts = list(db.collection("community_posts").stream())
    total_posts = len(posts)

    reported = sum(
        1 for p in posts if p.to_dict().get("reports_count", 0) > 0
    ) + sum(
        1 for p in performances if p.to_dict().get("reports_count", 0) > 0
    )

    campaigns = list(db.collection("campaigns").stream()) if _collection_exists(db, "campaigns") else []
    active_campaigns = sum(1 for c in campaigns if c.to_dict().get("status") == "Active")

    revenue = 0.0
    txs = list(db.collection("transactions").stream())
    for tx in txs:
        revenue += tx.to_dict().get("netAmount", 0)

    genre_counts = {}
    for doc in posts:
        for g in doc.to_dict().get("genres", []):
            genre_counts[g] = genre_counts.get(g, 0) + 1
    for doc in performances:
        for g in doc.to_dict().get("genres", []):
            genre_counts[g] = genre_counts.get(g, 0) + 1

    colors = ["#ffd426", "#3b82f6", "#22c55e", "#f59e0b", "#a855f7", "#9aa4b2"]
    genre_dist = [
        {"name": g, "value": c, "color": colors[i % len(colors)]}
        for i, (g, c) in enumerate(
            sorted(genre_counts.items(), key=lambda x: x[1], reverse=True)
        )
    ]

    all_content = posts + performances
    top_songs = sorted(
        all_content,
        key=lambda x: x.to_dict().get("plays_count", 0) or x.to_dict().get("viewers_count", 0),
        reverse=True,
    )[:10]
    top_songs_list = [
        {
            "title": s.to_dict().get("songTitle") or s.to_dict().get("title", ""),
            "artist": s.to_dict().get("songArtist") or s.to_dict().get("artistName", ""),
            "plays": s.to_dict().get("plays_count", 0) or s.to_dict().get("viewers_count", 0),
        }
        for s in top_songs
    ]

    return jsonify({
        "totalListeners": total_listeners,
        "totalArtists": total_artists,
        "totalPerformances": total_performances,
        "liveSessions": live_sessions,
        "totalPosts": total_posts,
        "activeCampaigns": active_campaigns,
        "totalRevenue": round(revenue / 100, 2),
        "reportedContent": reported,
        "genreDistribution": genre_dist,
        "topSongs": top_songs_list,
    })


def _collection_exists(db, name):
    try:
        list(db.collection(name).limit(1).stream())
        return True
    except Exception:
        return False


# ── Artists ─────────────────────────────────────────────────────

@admin_bp.route("/artists", methods=["GET"])
@require_auth
def list_artists():
    if not _require_admin():
        return jsonify({"detail": "Forbidden"}), 403

    db = _get_db()
    docs = db.collection("users").where("role", "==", "artist").stream()
    artists = [_user_to_artist(d, db) for d in docs]
    return jsonify({"artists": artists})


# ── Listeners ───────────────────────────────────────────────────

@admin_bp.route("/listeners", methods=["GET"])
@require_auth
def list_listeners():
    if not _require_admin():
        return jsonify({"detail": "Forbidden"}), 403

    db = _get_db()
    docs = db.collection("users").where("role", "==", "listener").stream()
    listeners = [_user_to_listener(d) for d in docs]
    return jsonify({"listeners": listeners})


# ── Songs (performances) ────────────────────────────────────────

@admin_bp.route("/songs", methods=["GET"])
@require_auth
def list_songs():
    if not _require_admin():
        return jsonify({"detail": "Forbidden"}), 403

    db = _get_db()
    docs = db.collection("performances").stream()

    artist_ids = set()
    perf_list = []
    for d in docs:
        aid = d.to_dict().get("artist_id", "")
        if aid:
            artist_ids.add(aid)
        perf_list.append(d)

    artist_names = {}
    for aid in artist_ids:
        udoc = db.collection("users").document(aid).get()
        if udoc.exists:
            ud = udoc.to_dict()
            artist_names[aid] = ud.get("artistName") or ud.get("name", aid)
        else:
            artist_names[aid] = aid

    songs = [_perf_to_song(d, artist_names) for d in perf_list]
    return jsonify({"songs": songs})


# ── Posts ────────────────────────────────────────────────────────

@admin_bp.route("/posts", methods=["GET"])
@require_auth
def list_posts():
    if not _require_admin():
        return jsonify({"detail": "Forbidden"}), 403

    db = _get_db()
    docs = db.collection("community_posts").stream()
    posts = [_post_to_community(d) for d in docs]
    return jsonify({"posts": posts})


# ── User status (approve/reject/suspend) ────────────────────────

@admin_bp.route("/users/<user_id>/status", methods=["PUT"])
@require_auth
def update_user_status(user_id):
    if not _require_admin():
        return jsonify({"detail": "Forbidden"}), 403

    body = request.get_json(force=True)
    new_status = body.get("status", "")
    if not new_status:
        return jsonify({"detail": "status is required"}), 400

    db = _get_db()
    doc = db.collection("users").document(user_id).get()
    if not doc.exists:
        return jsonify({"detail": "User not found"}), 404

    db.collection("users").document(user_id).set(
        {"status": new_status, "updatedAt": _now()}, merge=True
    )

    d = doc.to_dict()
    role = d.get("role", "listener")
    if role == "artist":
        return jsonify(_user_to_artist(db.collection("users").document(user_id).get(), db))
    else:
        return jsonify(_user_to_listener(db.collection("users").document(user_id).get()))


# ── Song moderation ─────────────────────────────────────────────

@admin_bp.route("/songs/<song_id>/moderation", methods=["PUT"])
@require_auth
def moderate_song(song_id):
    if not _require_admin():
        return jsonify({"detail": "Forbidden"}), 403

    body = request.get_json(force=True)
    new_status = body.get("status", "")
    if not new_status:
        return jsonify({"detail": "status is required"}), 400

    db = _get_db()
    doc = db.collection("performances").document(song_id).get()
    if not doc.exists:
        return jsonify({"detail": "Song not found"}), 404

    db.collection("performances").document(song_id).set(
        {"adminStatus": new_status, "updatedAt": _now()}, merge=True
    )

    updated = db.collection("performances").document(song_id).get()
    return jsonify(_perf_to_song(updated))


# ── Post moderation ─────────────────────────────────────────────

@admin_bp.route("/posts/<post_id>/moderation", methods=["PUT"])
@require_auth
def moderate_post(post_id):
    if not _require_admin():
        return jsonify({"detail": "Forbidden"}), 403

    body = request.get_json(force=True)
    new_status = body.get("status", "")
    if not new_status:
        return jsonify({"detail": "status is required"}), 400

    db = _get_db()
    doc = db.collection("community_posts").document(post_id).get()
    if not doc.exists:
        return jsonify({"detail": "Post not found"}), 404

    db.collection("community_posts").document(post_id).set(
        {"adminStatus": new_status, "updatedAt": _now()}, merge=True
    )

    updated = db.collection("community_posts").document(post_id).get()
    return jsonify(_post_to_community(updated))


@admin_bp.route("/posts/<post_id>", methods=["DELETE"])
@require_auth
def delete_post(post_id):
    if not _require_admin():
        return jsonify({"detail": "Forbidden"}), 403

    db = _get_db()
    doc = db.collection("community_posts").document(post_id).get()
    if not doc.exists:
        return jsonify({"detail": "Post not found"}), 404

    db.collection("community_posts").document(post_id).delete()
    return jsonify({"deleted": True})


# ── User stats (artist-stats / listener-stats) ──────────────────

@admin_bp.route("/users/<user_id>/artist-stats", methods=["GET"])
@require_auth
def get_artist_stats(user_id):
    if not _require_admin():
        return jsonify({"detail": "Forbidden"}), 403

    db = _get_db()
    user_doc = db.collection("users").document(user_id).get()
    if not user_doc.exists:
        return jsonify({"detail": "User not found"}), 404

    user = user_doc.to_dict()

    perfs = list(
        db.collection("performances").where("artist_id", "==", user_id).stream()
    )
    posts = list(
        db.collection("community_posts").where("author_id", "==", user_id).stream()
    )
    total_songs = len(perfs) + len(posts)

    return jsonify({
        "songs": total_songs,
        "followers": user.get("followersCount", 0),
        "verified": user.get("verified", False),
        "engagementRate": 0,
    })


@admin_bp.route("/users/<user_id>/listener-stats", methods=["GET"])
@require_auth
def get_listener_stats(user_id):
    if not _require_admin():
        return jsonify({"detail": "Forbidden"}), 403

    db = _get_db()
    user_doc = db.collection("users").document(user_id).get()
    if not user_doc.exists:
        return jsonify({"detail": "User not found"}), 404

    user = user_doc.to_dict()

    return jsonify({
        "songs": user.get("likedCount", 0),
        "posts": user.get("postsCount", 0),
        "dayStreak": user.get("dayStreak", 0),
    })


# ── Settings ────────────────────────────────────────────────────

@admin_bp.route("/settings", methods=["GET"])
@require_auth
def get_settings():
    if not _require_admin():
        return jsonify({"detail": "Forbidden"}), 403

    db = _get_db()
    doc = db.collection("settings").document("platform").get()
    if doc.exists:
        return jsonify(doc.to_dict())
    return jsonify({
        "maintenance": False,
        "newUser": True,
        "artist": True,
        "liveApproval": True,
        "songApproval": True,
        "platformName": "Sound Swipe",
        "supportEmail": "support@soundswipe.io",
        "timezone": "UTC",
    })


@admin_bp.route("/settings", methods=["PUT"])
@require_auth
def update_settings():
    if not _require_admin():
        return jsonify({"detail": "Forbidden"}), 403

    body = request.get_json(force=True)
    db = _get_db()
    db.collection("settings").document("platform").set(body, merge=True)
    return jsonify(body)


# ── Profile ─────────────────────────────────────────────────────

@admin_bp.route("/profile", methods=["GET"])
@require_auth
def get_profile():
    db = _get_db()
    uid = request.user["uid"]
    doc = db.collection("users").document(uid).get()
    if not doc.exists:
        return jsonify({
            "uid": uid,
            "email": request.user.get("email", ""),
            "name": request.user.get("name", "Super Admin"),
            "role": "admin",
            "status": "Active",
            "createdAt": "",
            "profileImageUrl": "",
        })

    d = doc.to_dict()
    return jsonify({
        "uid": uid,
        "email": d.get("email", request.user.get("email", "")),
        "name": d.get("name") or d.get("displayName") or request.user.get("name", "Super Admin"),
        "role": d.get("role", "admin"),
        "status": d.get("status", "Active"),
        "createdAt": _format_date(d.get("createdAt")),
        "profileImageUrl": d.get("profileImageUrl", ""),
    })


# ── CSV Export ───────────────────────────────────────────────────

def _to_csv_response(rows: list[dict], filename: str):
    if not rows:
        return Response("No data", status=404)
    output = io.StringIO()
    writer = csv.DictWriter(output, fieldnames=rows[0].keys())
    writer.writeheader()
    writer.writerows(rows)
    return Response(
        output.getvalue(),
        mimetype="text/csv",
        headers={"Content-Disposition": f"attachment;filename={filename}"},
    )


@admin_bp.route("/export/artists", methods=["GET"])
@require_auth
def export_artists():
    if not _require_admin():
        return jsonify({"detail": "Forbidden"}), 403
    db = _get_db()
    docs = db.collection("users").where("role", "==", "artist").stream()
    artists = [_user_to_artist(d, db) for d in docs]
    return _to_csv_response(artists, "artists.csv")


@admin_bp.route("/export/listeners", methods=["GET"])
@require_auth
def export_listeners():
    if not _require_admin():
        return jsonify({"detail": "Forbidden"}), 403
    db = _get_db()
    docs = db.collection("users").where("role", "==", "listener").stream()
    listeners = [_user_to_listener(d) for d in docs]
    return _to_csv_response(listeners, "listeners.csv")


@admin_bp.route("/export/songs", methods=["GET"])
@require_auth
def export_songs():
    if not _require_admin():
        return jsonify({"detail": "Forbidden"}), 403
    db = _get_db()
    docs = list(db.collection("performances").stream())

    artist_ids = set()
    for d in docs:
        aid = d.to_dict().get("artist_id", "")
        if aid:
            artist_ids.add(aid)

    artist_names = {}
    for aid in artist_ids:
        udoc = db.collection("users").document(aid).get()
        if udoc.exists:
            ud = udoc.to_dict()
            artist_names[aid] = ud.get("artistName") or ud.get("name", aid)
        else:
            artist_names[aid] = aid

    songs = [_perf_to_song(d, artist_names) for d in docs]
    return _to_csv_response(songs, "songs.csv")


@admin_bp.route("/export/posts", methods=["GET"])
@require_auth
def export_posts():
    if not _require_admin():
        return jsonify({"detail": "Forbidden"}), 403
    db = _get_db()
    docs = db.collection("community_posts").stream()
    posts = [_post_to_community(d) for d in docs]
    return _to_csv_response(posts, "posts.csv")
