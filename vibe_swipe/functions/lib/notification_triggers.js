"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.onPerformanceStatusChanged = exports.onPerformanceLike = exports.onPostLike = exports.onPostComment = exports.onNewFollower = void 0;
const functions = __importStar(require("firebase-functions"));
const firebase_admin_1 = require("./firebase-admin");
const notifications_1 = require("./notifications");
exports.onNewFollower = functions.firestore
    .document("users/{listenerId}/following/{artistId}")
    .onCreate(async (snap, context) => {
    const { listenerId, artistId } = context.params;
    const listenerDoc = await firebase_admin_1.db.collection("users").doc(listenerId).get();
    const listenerName = listenerDoc.data()?.username ||
        listenerDoc.data()?.name ||
        "Someone";
    await (0, notifications_1.sendNotification)(artistId, {
        type: "new_follower",
        title: "New Follower",
        body: `${listenerName} started following you`,
        data: { listenerId },
    });
});
exports.onPostComment = functions.firestore
    .document("posts/{postId}/comments/{commentId}")
    .onCreate(async (snap, context) => {
    const { postId, commentId } = context.params;
    const comment = snap.data();
    const authorId = comment.author_id;
    const postDoc = await firebase_admin_1.db.collection("posts").doc(postId).get();
    const postAuthorId = postDoc.data()?.author_id;
    if (!postAuthorId || postAuthorId === authorId)
        return;
    const commenterDoc = await firebase_admin_1.db.collection("users").doc(authorId).get();
    const commenterName = commenterDoc.data()?.username ||
        commenterDoc.data()?.name ||
        "Someone";
    await (0, notifications_1.sendNotification)(postAuthorId, {
        type: "post_comment",
        title: "New Comment",
        body: `${commenterName} commented on your post`,
        data: { postId, commentId },
    });
});
exports.onPostLike = functions.firestore
    .document("posts/{postId}/likes/{userId}")
    .onCreate(async (snap, context) => {
    const { postId, userId } = context.params;
    const postDoc = await firebase_admin_1.db.collection("posts").doc(postId).get();
    const postAuthorId = postDoc.data()?.author_id;
    if (!postAuthorId || postAuthorId === userId)
        return;
    const likerDoc = await firebase_admin_1.db.collection("users").doc(userId).get();
    const likerName = likerDoc.data()?.username ||
        likerDoc.data()?.name ||
        "Someone";
    await (0, notifications_1.sendNotification)(postAuthorId, {
        type: "post_like",
        title: "New Like",
        body: `${likerName} liked your post`,
        data: { postId },
    });
});
exports.onPerformanceLike = functions.firestore
    .document("performances/{performanceId}/likes/{userId}")
    .onCreate(async (snap, context) => {
    const { performanceId, userId } = context.params;
    const perfDoc = await firebase_admin_1.db
        .collection("performances")
        .doc(performanceId)
        .get();
    const artistId = perfDoc.data()?.artist_id;
    if (!artistId || artistId === userId)
        return;
    const likerDoc = await firebase_admin_1.db.collection("users").doc(userId).get();
    const likerName = likerDoc.data()?.username ||
        likerDoc.data()?.name ||
        "Someone";
    await (0, notifications_1.sendNotification)(artistId, {
        type: "performance_like",
        title: "Performance Like",
        body: `${likerName} liked your performance`,
        data: { performanceId },
    });
});
exports.onPerformanceStatusChanged = functions.firestore
    .document("performances/{performanceId}")
    .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const { performanceId } = context.params;
    if (before.status === after.status || after.status !== "live")
        return;
    const artistId = after.artist_id;
    const artistDoc = await firebase_admin_1.db.collection("users").doc(artistId).get();
    const artistName = artistDoc.data()?.artistName ||
        artistDoc.data()?.name ||
        "An artist";
    await (0, notifications_1.batchSendToFollowers)(artistId, {
        type: "live_stream_started",
        title: "Live Now!",
        body: `${artistName} is now live: ${after.title || "Performance"}`,
        data: { performanceId, artistId },
    });
});
//# sourceMappingURL=notification_triggers.js.map