from firebase_admin import firestore
from firebase_config import get_firestore_client
from datetime import datetime, timezone


def _now():
    return datetime.now(timezone.utc)


class FirestoreService:
    def __init__(self):
        self.db = get_firestore_client()

    @property
    def _users(self):
        return self.db.collection("users")

    @property
    def _posts(self):
        return self.db.collection("posts")

    @property
    def _chats(self):
        return self.db.collection("chats")

    @property
    def _performances(self):
        return self.db.collection("performances")

    @property
    def _discussions(self):
        return self.db.collection("discussions")

    @property
    def _notifications(self):
        return self.db.collection("notifications")

    # ── Users ──────────────────────────────────────────────

    def create_user(self, uid: str, data: dict) -> dict:
        doc = {
            "uid": uid,
            "name": data.get("name", ""),
            "email": data.get("email", ""),
            "role": data.get("role", "listener"),
            "likedCount": 0,
            "savedCount": 0,
            "createdAt": _now(),
            "updatedAt": _now(),
        }
        self._users.document(uid).set(doc)
        return doc

    def get_user(self, uid: str) -> dict | None:
        doc = self._users.document(uid).get()
        if doc.exists:
            data = doc.to_dict()
            data["uid"] = doc.id
            return data
        return None

    def update_user(self, uid: str, data: dict) -> dict:
        data["updatedAt"] = _now()
        self._users.document(uid).set(data, merge=True)
        return self.get_user(uid) or {}

    def get_user_role(self, uid: str) -> str | None:
        doc = self._users.document(uid).get()
        if doc.exists:
            return doc.to_dict().get("role")
        return None

    def save_artist_profile(self, uid: str, data: dict) -> dict:
        update = {
            "artistName": data["artistName"],
            "bio": data.get("bio", ""),
            "genres": data.get("genres", []),
            "socialLinks": {
                "spotify": data.get("spotifyUrl", ""),
                "youtube": data.get("youtubeUrl", ""),
                "instagram": data.get("instagramUrl", ""),
            },
            "isPublicProfile": data.get("isPublicProfile", True),
            "updatedAt": _now(),
        }
        if data.get("profileImageUrl"):
            update["profileImageUrl"] = data["profileImageUrl"]
        else:
            update["profileImageUrl"] = ""
        if data.get("coverUrl"):
            update["coverUrl"] = data["coverUrl"]
        self._users.document(uid).set(update, merge=True)
        return self.get_user(uid) or {}

    def save_listener_profile(self, uid: str, data: dict) -> dict:
        update = {
            "username": data["username"],
            "favoriteGenres": data.get("favoriteGenres", []),
            "dislikedGenres": data.get("dislikedGenres", []),
            "updatedAt": _now(),
        }
        self._users.document(uid).set(update, merge=True)
        return self.get_user(uid) or {}

    # ── Posts / Feed ───────────────────────────────────────

    def create_post(self, author_id: str, data: dict) -> dict:
        doc = {
            "author_id": author_id,
            "caption": data.get("caption", ""),
            "songTitle": data.get("songTitle", ""),
            "songArtist": data.get("songArtist", ""),
            "audioUrl": data.get("audioUrl"),
            "imageUrl": data.get("imageUrl"),
            "genres": data.get("genres", []),
            "likes_count": 0,
            "comments_count": 0,
            "swipes_yes_count": 0,
            "swipes_no_count": 0,
            "plays_count": 0,
            "createdAt": _now(),
            "updatedAt": _now(),
        }
        ref = self._posts.add(doc)
        doc["id"] = ref[1].id
        return doc

    def get_post(self, post_id: str) -> dict | None:
        doc = self._posts.document(post_id).get()
        if doc.exists:
            data = doc.to_dict()
            data["id"] = doc.id
            return data
        return None

    def get_feed(self, limit: int = 20, start_after: str | None = None) -> list[dict]:
        query = self._posts.order_by("createdAt", direction=firestore.Query.DESCENDING)
        if start_after:
            last_doc = self._posts.document(start_after).get()
            if last_doc.exists:
                query = query.start_after(last_doc)
        docs = query.limit(limit).stream()
        results = []
        for doc in docs:
            data = doc.to_dict()
            data["id"] = doc.id
            results.append(data)
        return results

    def delete_post(self, post_id: str, author_id: str) -> bool:
        doc = self._posts.document(post_id).get()
        if not doc.exists:
            return False
        if doc.to_dict().get("author_id") != author_id:
            return False
        self._posts.document(post_id).delete()
        return True

    def like_post(self, post_id: str, user_id: str) -> dict:
        likes_ref = self._posts.document(post_id).collection("likes")
        existing = likes_ref.document(user_id).get()
        if existing.exists:
            likes_ref.document(user_id).delete()
            self._posts.document(post_id).update(
                {"likes_count": firestore.Increment(-1)}
            )
            return {"liked": False}
        likes_ref.document(user_id).set({
            "user_id": user_id,
            "createdAt": _now(),
        })
        self._posts.document(post_id).update(
            {"likes_count": firestore.Increment(1)}
        )
        return {"liked": True}

    def record_swipe(self, user_id: str, post_id: str, liked: bool) -> dict:
        swipe_ref = self._users.document(user_id).collection("swipes").document(post_id)

        existing = swipe_ref.get()
        if existing.exists:
            prev_liked = existing.to_dict().get("liked")
            if prev_liked == liked:
                swipe_ref.delete()
                field = "swipes_yes_count" if liked else "swipes_no_count"
                self._posts.document(post_id).update({field: firestore.Increment(-1)})
                if liked:
                    self._users.document(user_id).update({"likedCount": firestore.Increment(-1)})
                return {"post_id": post_id, "liked": liked, "removed": True}
            else:
                swipe_ref.set({"post_id": post_id, "liked": liked, "createdAt": _now()})
                self._posts.document(post_id).update({
                    "swipes_yes_count": firestore.Increment(1 if liked else -1),
                    "swipes_no_count": firestore.Increment(-1 if liked else 1),
                })
                if liked:
                    self._users.document(user_id).update({"likedCount": firestore.Increment(1)})
                else:
                    self._users.document(user_id).update({"likedCount": firestore.Increment(-1)})
                return {"post_id": post_id, "liked": liked, "changed": True}

        swipe_ref.set({
            "post_id": post_id,
            "liked": liked,
            "createdAt": _now(),
        })
        field = "swipes_yes_count" if liked else "swipes_no_count"
        self._posts.document(post_id).update({field: firestore.Increment(1)})
        if liked:
            self._users.document(user_id).update({"likedCount": firestore.Increment(1)})
        return {"post_id": post_id, "liked": liked}

    # ── Comments ───────────────────────────────────────────

    def create_comment(self, post_id: str, author_id: str, text: str) -> dict:
        comment = {
            "author_id": author_id,
            "text": text,
            "createdAt": _now(),
        }
        ref = self._posts.document(post_id).collection("comments").add(comment)
        self._posts.document(post_id).update(
            {"comments_count": firestore.Increment(1)}
        )
        comment["id"] = ref[1].id
        return comment

    def get_comments(self, post_id: str, limit: int = 20) -> list[dict]:
        docs = (
            self._posts.document(post_id)
            .collection("comments")
            .order_by("createdAt", direction=firestore.Query.DESCENDING)
            .limit(limit)
            .stream()
        )
        results = []
        for doc in docs:
            data = doc.to_dict()
            data["id"] = doc.id
            results.append(data)
        return results

    # ── Discussions ────────────────────────────────────────

    def create_discussion(self, author_id: str, data: dict) -> dict:
        doc = {
            "author_id": author_id,
            "title": data["title"],
            "body": data.get("body", ""),
            "genres": data.get("genres", []),
            "replies_count": 0,
            "createdAt": _now(),
            "updatedAt": _now(),
        }
        ref = self._discussions.add(doc)
        doc["id"] = ref[1].id
        return doc

    def get_discussions(self, limit: int = 20, start_after: str | None = None) -> list[dict]:
        query = self._discussions.order_by("createdAt", direction=firestore.Query.DESCENDING)
        if start_after:
            last_doc = self._discussions.document(start_after).get()
            if last_doc.exists:
                query = query.start_after(last_doc)
        docs = query.limit(limit).stream()
        results = []
        for doc in docs:
            data = doc.to_dict()
            data["id"] = doc.id
            results.append(data)
        return results

    def create_reply(self, discussion_id: str, author_id: str, text: str) -> dict:
        reply = {
            "author_id": author_id,
            "text": text,
            "createdAt": _now(),
        }
        ref = self._discussions.document(discussion_id).collection("replies").add(reply)
        self._discussions.document(discussion_id).update(
            {"replies_count": firestore.Increment(1)}
        )
        reply["id"] = ref[1].id
        return reply

    def get_replies(self, discussion_id: str, limit: int = 20) -> list[dict]:
        docs = (
            self._discussions.document(discussion_id)
            .collection("replies")
            .order_by("createdAt", direction=firestore.Query.DESCENDING)
            .limit(limit)
            .stream()
        )
        results = []
        for doc in docs:
            data = doc.to_dict()
            data["id"] = doc.id
            results.append(data)
        return results

    # ── Chat ───────────────────────────────────────────────

    def get_or_create_chat(self, user1_id: str, user2_id: str) -> dict:
        sorted_ids = sorted([user1_id, user2_id])
        chat_id = f"{sorted_ids[0]}_{sorted_ids[1]}"
        chat_ref = self._chats.document(chat_id)
        chat_doc = chat_ref.get()
        if chat_doc.exists:
            data = chat_doc.to_dict()
            data["id"] = chat_id
            return data
        chat_data = {
            "user1_id": sorted_ids[0],
            "user2_id": sorted_ids[1],
            "lastMessage": "",
            "createdAt": _now(),
            "updatedAt": _now(),
        }
        chat_ref.set(chat_data)
        chat_data["id"] = chat_id
        return chat_data

    def send_chat_message(self, sender_id: str, receiver_id: str, text: str) -> dict:
        sorted_ids = sorted([sender_id, receiver_id])
        chat_id = f"{sorted_ids[0]}_{sorted_ids[1]}"

        chat_ref = self._chats.document(chat_id)
        chat_doc = chat_ref.get()
        if not chat_doc.exists:
            chat_ref.set({
                "user1_id": sorted_ids[0],
                "user2_id": sorted_ids[1],
                "lastMessage": text,
                "createdAt": _now(),
                "updatedAt": _now(),
            })

        message = {
            "sender_id": sender_id,
            "text": text,
            "createdAt": _now(),
        }
        ref = chat_ref.collection("messages").add(message)
        chat_ref.update({"lastMessage": text, "updatedAt": _now()})
        message["id"] = ref[1].id
        return message

    def get_chat_messages(self, user1_id: str, user2_id: str, limit: int = 50) -> list[dict]:
        sorted_ids = sorted([user1_id, user2_id])
        chat_id = f"{sorted_ids[0]}_{sorted_ids[1]}"
        docs = (
            self._chats.document(chat_id)
            .collection("messages")
            .order_by("createdAt", direction=firestore.Query.DESCENDING)
            .limit(limit)
            .stream()
        )
        results = []
        for doc in docs:
            data = doc.to_dict()
            data["id"] = doc.id
            results.append(data)
        return results

    def get_user_chats(self, user_id: str) -> list[dict]:
        q1 = self._chats.where("user1_id", "==", user_id).stream()
        q2 = self._chats.where("user2_id", "==", user_id).stream()
        chats = []
        for doc in list(q1) + list(q2):
            data = doc.to_dict()
            data["id"] = doc.id
            chats.append(data)
        return chats

    # ── Performances / Live Sessions ───────────────────────

    def create_performance(self, artist_id: str, data: dict) -> dict:
        doc = {
            "artist_id": artist_id,
            "title": data["title"],
            "description": data.get("description", ""),
            "genres": data.get("genres", []),
            "status": data.get("status", "upcoming"),
            "type": data.get("type", "live"),
            "thumbnailUrl": data.get("thumbnailUrl", ""),
            "videoUrl": data.get("videoUrl", ""),
            "viewers_count": 0,
            "likes_count": 0,
            "saves_count": 0,
            "isPaid": data.get("isPaid", False),
            "ticketPrice": data.get("ticketPrice", 0.0),
            "paidUsers": [],
            "createdAt": _now(),
            "updatedAt": _now(),
        }
        ref = self._performances.add(doc)
        doc["id"] = ref[1].id
        return doc

    def get_performances(self, limit: int = 20, status: str | None = None, artist_id: str | None = None) -> list[dict]:
        query = self._performances.order_by("createdAt", direction=firestore.Query.DESCENDING)
        if status:
            query = query.where("status", "==", status)
        if artist_id:
            query = query.where("artist_id", "==", artist_id)
        docs = query.limit(limit).stream()
        results = []
        for doc in docs:
            data = doc.to_dict()
            data["id"] = doc.id
            results.append(data)
        return results

    def update_performance(self, performance_id: str, artist_id: str, data: dict) -> dict | None:
        doc = self._performances.document(performance_id).get()
        if not doc.exists:
            return None
        if doc.to_dict().get("artist_id") != artist_id:
            return None
        data["updatedAt"] = _now()
        self._performances.document(performance_id).set(data, merge=True)
        updated = self._performances.document(performance_id).get()
        result = updated.to_dict()
        result["id"] = performance_id
        return result

    def delete_performance(self, performance_id: str, artist_id: str) -> bool:
        doc = self._performances.document(performance_id).get()
        if not doc.exists:
            return False
        if doc.to_dict().get("artist_id") != artist_id:
            return False
        self._performances.document(performance_id).delete()
        return True

    def join_performance(self, performance_id: str, viewer_id: str) -> dict:
        viewers_ref = (
            self._performances.document(performance_id).collection("viewers")
        )
        existing = viewers_ref.document(viewer_id).get()
        if not existing.exists:
            viewers_ref.document(viewer_id).set({
                "viewer_id": viewer_id,
                "joinedAt": _now(),
            })
            self._performances.document(performance_id).update(
                {"viewers_count": firestore.Increment(1)}
            )
        return {"joined": True}

    def leave_performance(self, performance_id: str, viewer_id: str) -> dict:
        viewers_ref = (
            self._performances.document(performance_id).collection("viewers")
        )
        existing = viewers_ref.document(viewer_id).get()
        if existing.exists:
            viewers_ref.document(viewer_id).delete()
            self._performances.document(performance_id).update(
                {"viewers_count": firestore.Increment(-1)}
            )
        return {"left": True}


    def like_performance(self, performance_id: str, user_id: str) -> dict:
        likes_ref = self._performances.document(performance_id).collection("likes")
        existing = likes_ref.document(user_id).get()
        if existing.exists:
            likes_ref.document(user_id).delete()
            self._performances.document(performance_id).update(
                {"likes_count": firestore.Increment(-1)}
            )
            self._users.document(user_id).update({"likedCount": firestore.Increment(-1)})
            return {"liked": False}
        likes_ref.document(user_id).set({
            "user_id": user_id,
            "createdAt": _now(),
        })
        self._performances.document(performance_id).update(
            {"likes_count": firestore.Increment(1)}
        )
        self._users.document(user_id).update({"likedCount": firestore.Increment(1)})
        return {"liked": True}

    def save_performance(self, performance_id: str, user_id: str) -> dict:
        saves_ref = self._performances.document(performance_id).collection("saves")
        existing = saves_ref.document(user_id).get()
        if existing.exists:
            saves_ref.document(user_id).delete()
            self._performances.document(performance_id).update(
                {"saves_count": firestore.Increment(-1)}
            )
            self._users.document(user_id).update({"savedCount": firestore.Increment(-1)})
            new_count = self._users.document(user_id).get().to_dict().get("savedCount", 0)
            return {"saved": False, "savedCount": new_count}
        saves_ref.document(user_id).set({
            "user_id": user_id,
            "createdAt": _now(),
        })
        self._performances.document(performance_id).update(
            {"saves_count": firestore.Increment(1)}
        )
        self._users.document(user_id).update({"savedCount": firestore.Increment(1)})
        new_count = self._users.document(user_id).get().to_dict().get("savedCount", 0)
        return {"saved": True, "savedCount": new_count}

    def record_performance_view(self, performance_id: str, viewer_id: str) -> dict:
        views_ref = self._performances.document(performance_id).collection("views")
        existing = views_ref.document(viewer_id).get()
        if not existing.exists:
            views_ref.document(viewer_id).set({
                "viewer_id": viewer_id,
                "viewedAt": _now(),
            })
            self._performances.document(performance_id).update(
                {"viewers_count": firestore.Increment(1)}
            )
            return {"viewed": True, "newView": True}
        return {"viewed": True, "newView": False}

    def get_performance_user_state(self, performance_id: str, user_id: str) -> dict:
        likes_ref = self._performances.document(performance_id).collection("likes")
        is_liked = likes_ref.document(user_id).get().exists

        saves_ref = self._performances.document(performance_id).collection("saves")
        is_saved = saves_ref.document(user_id).get().exists

        return {"isLiked": is_liked, "isSaved": is_saved}

    # ── Search ─────────────────────────────────────────────

    def search_users(
        self, query: str, genre: str | None = None, limit: int = 20
    ) -> list[dict]:
        results = []
        seen_uids = set()

        # Search by name (artistName or name)
        name_query = self._users.where("name", ">=", query).where(
            "name", "<=", query + "\uf8ff"
        ).limit(limit).stream()
        for doc in name_query:
            data = doc.to_dict()
            data["uid"] = doc.id
            if doc.id not in seen_uids:
                results.append(data)
                seen_uids.add(doc.id)

        # Search by artistName
        artist_name_query = self._users.where("artistName", ">=", query).where(
            "artistName", "<=", query + "\uf8ff"
        ).limit(limit).stream()
        for doc in artist_name_query:
            data = doc.to_dict()
            data["uid"] = doc.id
            if doc.id not in seen_uids:
                results.append(data)
                seen_uids.add(doc.id)

        # Search by username (listener accounts)
        username_query = self._users.where("username", ">=", query).where(
            "username", "<=", query + "\uf8ff"
        ).limit(limit).stream()
        for doc in username_query:
            data = doc.to_dict()
            data["uid"] = doc.id
            if doc.id not in seen_uids:
                results.append(data)
                seen_uids.add(doc.id)

        # Filter by genre if specified
        if genre:
            genre_query = self._users.where("genres", "array_contains", genre).limit(
                limit
            ).stream()
            for doc in genre_query:
                data = doc.to_dict()
                data["uid"] = doc.id
                if doc.id not in seen_uids:
                    results.append(data)
                    seen_uids.add(doc.id)

        return results[:limit]

    def search_posts(
        self, query: str, genre: str | None = None, limit: int = 20
    ) -> list[dict]:
        results = []
        caption_query = self._posts.where("caption", ">=", query).where(
            "caption", "<=", query + "\uf8ff"
        ).limit(limit).stream()
        for doc in caption_query:
            data = doc.to_dict()
            data["id"] = doc.id
            results.append(data)

        if genre:
            genre_query = self._posts.where("genres", "array_contains", genre).limit(
                limit
            ).stream()
            for doc in genre_query:
                data = doc.to_dict()
                data["id"] = doc.id
                if data["id"] not in [r["id"] for r in results]:
                    results.append(data)

        return results[:limit]

    def get_trending_genres(self, limit: int = 10) -> list[dict]:
        genre_counts: dict[str, int] = {}
        docs = self._posts.limit(100).stream()
        for doc in docs:
            for g in doc.to_dict().get("genres", []):
                genre_counts[g] = genre_counts.get(g, 0) + 1
        sorted_genres = sorted(genre_counts.items(), key=lambda x: x[1], reverse=True)
        return [{"genre": g, "count": c} for g, c in sorted_genres[:limit]]

    def get_trending_artists(self, limit: int = 10) -> list[dict]:
        docs = (
            self._users.where("role", "==", "artist")
            .order_by("followersCount", direction=firestore.Query.DESCENDING)
            .limit(limit)
            .stream()
        )
        results = []
        for doc in docs:
            data = doc.to_dict()
            data["uid"] = doc.id
            results.append({
                "uid": doc.id,
                "name": data.get("artistName") or data.get("name", ""),
                "genres": data.get("genres", []),
                "profileImageUrl": data.get("profileImageUrl", ""),
                "followersCount": data.get("followersCount", 0),
            })
        return results

    # ── Notifications ──────────────────────────────────────

    def create_notification(self, user_id: str, data: dict) -> dict:
        doc = {
            "type": data.get("type", ""),
            "title": data.get("title", ""),
            "body": data.get("body", ""),
            "data": data.get("data", {}),
            "read": False,
            "createdAt": _now(),
        }
        ref = self._notifications.document(user_id).collection("items").add(doc)
        doc["id"] = ref[1].id
        return doc

    def get_notifications(self, user_id: str, limit: int = 20) -> list[dict]:
        docs = (
            self._notifications.document(user_id)
            .collection("items")
            .order_by("createdAt", direction=firestore.Query.DESCENDING)
            .limit(limit)
            .stream()
        )
        results = []
        for doc in docs:
            data = doc.to_dict()
            data["id"] = doc.id
            results.append(data)
        return results

    def mark_notification_read(self, user_id: str, notification_id: str) -> bool:
        ref = (
            self._notifications.document(user_id)
            .collection("items")
            .document(notification_id)
        )
        doc = ref.get()
        if not doc.exists:
            return False
        ref.update({"read": True})
        return True

    # ── Artist Stats ──────────────────────────────────────

    def get_artist_stats(self, artist_id: str) -> dict:
        posts_query = self._posts.where("author_id", "==", artist_id).stream()
        posts = []
        for doc in posts_query:
            data = doc.to_dict()
            data["id"] = doc.id
            posts.append(data)

        perf_query = self._performances.where("artist_id", "==", artist_id).stream()
        performances = []
        for doc in perf_query:
            data = doc.to_dict()
            data["id"] = doc.id
            performances.append(data)

        all_items = posts + performances
        total_tracks = len(all_items)
        total_likes = sum(p.get("likes_count", 0) for p in all_items)
        total_saves = sum(p.get("saves_count", 0) for p in all_items)
        total_comments = sum(p.get("comments_count", 0) for p in all_items)
        total_yes = sum(p.get("swipes_yes_count", 0) for p in all_items)
        total_no = sum(p.get("swipes_no_count", 0) for p in all_items)
        total_plays = sum(p.get("plays_count", 0) or p.get("viewers_count", 0) for p in all_items)

        engagement_rate = 0.0
        if total_plays > 0:
            engagement_rate = round(((total_likes + total_saves + total_comments) / total_plays) * 100, 1)

        user_doc = self._users.document(artist_id).get()
        followers_count = user_doc.to_dict().get("followersCount", 0) if user_doc.exists else 0

        top_tracks = sorted(all_items, key=lambda p: p.get("plays_count", 0) or p.get("viewers_count", 0), reverse=True)[:5]

        return {
            "totalTracks": total_tracks,
            "totalLikes": total_likes,
            "totalSaves": total_saves,
            "totalComments": total_comments,
            "yesCount": total_yes,
            "noCount": total_no,
            "totalPlays": total_plays,
            "engagementRate": engagement_rate,
            "followersCount": followers_count,
            "topTracks": [
                {
                    "id": t["id"],
                    "title": t.get("songTitle") or t.get("title", ""),
                    "artist": t.get("songArtist") or "",
                    "plays": t.get("plays_count", 0) or t.get("viewers_count", 0),
                    "likes": t.get("likes_count", 0),
                    "saves": t.get("saves_count", 0),
                    "yesCount": t.get("swipes_yes_count", 0),
                }
                for t in top_tracks
            ],
        }

    def get_artist_analytics(self, artist_id: str) -> dict:
        stats = self.get_artist_stats(artist_id)

        daily_plays = {}
        daily_saves = {}

        posts_query = self._posts.where("author_id", "==", artist_id).stream()
        for doc in posts_query:
            post = doc.to_dict()
            created = post.get("createdAt")
            if created:
                day = created.strftime("%Y-%m-%d") if hasattr(created, "strftime") else str(created)[:10]
                daily_plays[day] = daily_plays.get(day, 0) + post.get("plays_count", 0)
                daily_saves[day] = daily_saves.get(day, 0) + post.get("likes_count", 0)

        perf_query = self._performances.where("artist_id", "==", artist_id).stream()
        for doc in perf_query:
            perf = doc.to_dict()
            created = perf.get("createdAt")
            if created:
                day = created.strftime("%Y-%m-%d") if hasattr(created, "strftime") else str(created)[:10]
                daily_plays[day] = daily_plays.get(day, 0) + perf.get("viewers_count", 0)

        genre_counts = {}
        for item in stats.get("topTracks", []):
            pass

        all_query1 = self._posts.where("author_id", "==", artist_id).stream()
        for doc in all_query1:
            for g in doc.to_dict().get("genres", []):
                genre_counts[g] = genre_counts.get(g, 0) + 1

        all_query2 = self._performances.where("artist_id", "==", artist_id).stream()
        for doc in all_query2:
            for g in doc.to_dict().get("genres", []):
                genre_counts[g] = genre_counts.get(g, 0) + 1

        return {
            **stats,
            "dailyPlays": daily_plays,
            "dailySaves": daily_saves,
            "genreBreakdown": [{"genre": g, "count": c} for g, c in genre_counts.items()],
        }

    def increment_post_plays(self, post_id: str) -> None:
        self._posts.document(post_id).update({"plays_count": firestore.Increment(1)})

    # ── Follow ───────────────────────────────────────────

    def follow_artist(self, follower_id: str, artist_id: str) -> dict:
        if follower_id == artist_id:
            return {"followed": False, "detail": "Cannot follow yourself"}

        follow_ref = self._users.document(follower_id).collection("following").document(artist_id)
        existing = follow_ref.get()

        if existing.exists:
            follow_ref.delete()
            self._users.document(artist_id).update(
                {"followersCount": firestore.Increment(-1)}
            )
            return {"followed": False}

        follow_ref.set({
            "artist_id": artist_id,
            "createdAt": _now(),
        })
        self._users.document(artist_id).update(
            {"followersCount": firestore.Increment(1)}
        )
        return {"followed": True}

    def is_following(self, follower_id: str, artist_id: str) -> bool:
        follow_ref = self._users.document(follower_id).collection("following").document(artist_id)
        return follow_ref.get().exists

    def get_followers_count(self, artist_id: str) -> int:
        user_doc = self._users.document(artist_id).get()
        if user_doc.exists:
            return user_doc.to_dict().get("followersCount", 0)
        return 0

    def get_user_library_stats(self, user_id: str) -> dict:
        user_doc = self._users.document(user_id).get()
        if user_doc.exists:
            data = user_doc.to_dict()
            return {
                "likedCount": data.get("likedCount", 0),
                "savedCount": data.get("savedCount", 0),
            }
        return {"likedCount": 0, "savedCount": 0}

    def get_saved_songs(self, user_id: str) -> list[dict]:
        results = []
        docs = self._performances.stream()
        for doc in docs:
            saves_ref = doc.reference.collection("saves")
            save_doc = saves_ref.document(user_id).get()
            if save_doc.exists:
                data = doc.to_dict()
                data["id"] = doc.id
                results.append(data)
        return results

    def get_listening_history(self, user_id: str) -> list[dict]:
        results = []
        docs = self._performances.stream()
        for doc in docs:
            views_ref = doc.reference.collection("views")
            view_doc = views_ref.document(user_id).get()
            if view_doc.exists:
                data = doc.to_dict()
                data["id"] = doc.id
                view_data = view_doc.to_dict()
                data["viewedAt"] = view_data.get("viewedAt")
                results.append(data)
        return results


db = FirestoreService()
