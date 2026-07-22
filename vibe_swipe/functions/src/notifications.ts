import * as admin from "firebase-admin";
import { db, messaging } from "./firebase-admin";

interface NotificationPayload {
  type: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

const PREF_MAP: Record<string, string> = {
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

export async function sendNotification(
  userId: string,
  notification: NotificationPayload
): Promise<void> {
  const enabled = await getNotificationPreferences(userId, notification.type);
  if (!enabled) return;

  const docRef = db
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

  const userDoc = await db.collection("users").doc(userId).get();
  const fcmToken = userDoc.data()?.fcmToken;
  if (!fcmToken) return;

  try {
    await messaging.send({
      token: fcmToken,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: notification.data || {},
      android: { notification: { channelId: "high_importance_channel" } },
      apns: { payload: { aps: { sound: "default" } } },
    });
  } catch (e: any) {
    if (e.code === "messaging/registration-token-not-registered") {
      await db.collection("users").doc(userId).update({ fcmToken: null });
    }
  }
}

async function getNotificationPreferences(
  userId: string,
  type: string
): Promise<boolean> {
  const userDoc = await db.collection("users").doc(userId).get();
  const data = userDoc.data();
  if (!data) return false;

  const notifPrefs = data.notificationPrefs || {};
  const prefKey = PREF_MAP[type];
  if (!prefKey) return true;

  return notifPrefs[prefKey] !== false;
}

export async function batchSendToFollowers(
  artistId: string,
  notification: NotificationPayload
): Promise<void> {
  const followersSnapshot = await db
    .collectionGroup("following")
    .where("artist_id", "==", artistId)
    .get();

  const promises = followersSnapshot.docs.map((doc) => {
    const followerId = doc.ref.parent.parent?.id;
    if (!followerId) return Promise.resolve();
    return sendNotification(followerId, notification);
  });

  await Promise.allSettled(promises);
}
