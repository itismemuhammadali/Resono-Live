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
exports.batchSendToFollowers = exports.sendNotification = void 0;
const admin = __importStar(require("firebase-admin"));
const firebase_admin_1 = require("./firebase-admin");
const PREF_MAP = {
    post_comment: "trackComments",
    post_like: "trackComments",
    performance_like: "trackPerformance",
    new_follower: "newFollowers",
    live_stream_started: "trackPerformance",
    scheduled_session_reminder: "trackPerformance",
    tip_received: "marketingUpdates",
    payout_processed: "marketingUpdates",
    new_performance_upload: "newSongs",
    payment_confirmed: "newSongs",
    payment_failed: "newSongs",
};
async function sendNotification(userId, notification) {
    const enabled = await getNotificationPreferences(userId, notification.type);
    if (!enabled)
        return;
    const docRef = firebase_admin_1.db
        .collection("notifications")
        .doc();
    await docRef.set({
        userId,
        type: notification.type,
        title: notification.title,
        body: notification.body,
        fullBody: notification.body,
        data: notification.data || {},
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    const userDoc = await firebase_admin_1.db.collection("users").doc(userId).get();
    const fcmToken = userDoc.data()?.fcmToken;
    if (!fcmToken)
        return;
    try {
        await firebase_admin_1.messaging.send({
            token: fcmToken,
            notification: {
                title: notification.title,
                body: notification.body,
            },
            data: notification.data || {},
            android: { notification: { channelId: "high_importance_channel" } },
            apns: { payload: { aps: { sound: "default" } } },
        });
    }
    catch (e) {
        if (e.code === "messaging/registration-token-not-registered") {
            await firebase_admin_1.db.collection("users").doc(userId).update({ fcmToken: null });
        }
    }
}
exports.sendNotification = sendNotification;
async function getNotificationPreferences(userId, type) {
    const userDoc = await firebase_admin_1.db.collection("users").doc(userId).get();
    const data = userDoc.data();
    if (!data)
        return false;
    const notifPrefs = data.notificationPrefs || {};
    const prefKey = PREF_MAP[type];
    if (!prefKey)
        return true;
    return notifPrefs[prefKey] !== false;
}
async function batchSendToFollowers(artistId, notification) {
    const followersSnapshot = await firebase_admin_1.db
        .collectionGroup("following")
        .where("artist_id", "==", artistId)
        .get();
    const promises = followersSnapshot.docs.map((doc) => {
        const followerId = doc.ref.parent.parent?.id;
        if (!followerId)
            return Promise.resolve();
        return sendNotification(followerId, notification);
    });
    await Promise.allSettled(promises);
}
exports.batchSendToFollowers = batchSendToFollowers;
//# sourceMappingURL=notifications.js.map