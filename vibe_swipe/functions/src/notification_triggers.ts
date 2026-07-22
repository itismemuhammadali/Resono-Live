import * as functions from "firebase-functions";
import { db } from "./firebase-admin";
import { sendNotification, batchSendToFollowers } from "./notifications";

export const onNewFollower = functions.firestore
  .document("users/{listenerId}/following/{artistId}")
  .onCreate(async (snap, context) => {
    const { listenerId, artistId } = context.params;
    const listenerDoc = await db.collection("users").doc(listenerId).get();
    const listenerName =
      listenerDoc.data()?.username ||
      listenerDoc.data()?.name ||
      "Someone";

    await sendNotification(artistId, {
      type: "new_follower",
      title: "New Follower",
      body: `${listenerName} started following you`,
      data: { listenerId },
    });
  });

export const onPostComment = functions.firestore
  .document("posts/{postId}/comments/{commentId}")
  .onCreate(async (snap, context) => {
    const { postId, commentId } = context.params;
    const comment = snap.data();
    const authorId = comment.author_id;

    const postDoc = await db.collection("posts").doc(postId).get();
    const postAuthorId = postDoc.data()?.author_id;
    if (!postAuthorId || postAuthorId === authorId) return;

    const commenterDoc = await db.collection("users").doc(authorId).get();
    const commenterName =
      commenterDoc.data()?.username ||
      commenterDoc.data()?.name ||
      "Someone";

    await sendNotification(postAuthorId, {
      type: "post_comment",
      title: "New Comment",
      body: `${commenterName} commented on your post`,
      data: { postId, commentId },
    });
  });

export const onPostLike = functions.firestore
  .document("posts/{postId}/likes/{userId}")
  .onCreate(async (snap, context) => {
    const { postId, userId } = context.params;

    const postDoc = await db.collection("posts").doc(postId).get();
    const postAuthorId = postDoc.data()?.author_id;
    if (!postAuthorId || postAuthorId === userId) return;

    const likerDoc = await db.collection("users").doc(userId).get();
    const likerName =
      likerDoc.data()?.username ||
      likerDoc.data()?.name ||
      "Someone";

    await sendNotification(postAuthorId, {
      type: "post_like",
      title: "New Like",
      body: `${likerName} liked your post`,
      data: { postId },
    });
  });

export const onPerformanceLike = functions.firestore
  .document("performances/{performanceId}/likes/{userId}")
  .onCreate(async (snap, context) => {
    const { performanceId, userId } = context.params;

    const perfDoc = await db
      .collection("performances")
      .doc(performanceId)
      .get();
    const artistId = perfDoc.data()?.artist_id;
    if (!artistId || artistId === userId) return;

    const likerDoc = await db.collection("users").doc(userId).get();
    const likerName =
      likerDoc.data()?.username ||
      likerDoc.data()?.name ||
      "Someone";

    await sendNotification(artistId, {
      type: "performance_like",
      title: "Performance Like",
      body: `${likerName} liked your performance`,
      data: { performanceId },
    });
  });

export const onPerformanceStatusChanged = functions.firestore
  .document("performances/{performanceId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const { performanceId } = context.params;

    if (before.status === after.status || after.status !== "live") return;

    const artistId = after.artist_id;
    const artistDoc = await db.collection("users").doc(artistId).get();
    const artistName =
      artistDoc.data()?.artistName ||
      artistDoc.data()?.name ||
      "An artist";

    await batchSendToFollowers(artistId, {
      type: "live_stream_started",
      title: "Live Now!",
      body: `${artistName} is now live: ${after.title || "Performance"}`,
      data: { performanceId, artistId },
    });
  });
