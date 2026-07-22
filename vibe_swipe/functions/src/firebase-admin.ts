import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK once
// Cloud Functions automatically uses the project's service account
if (!admin.apps.length) {
  admin.initializeApp();
}

export const db = admin.firestore();
export const auth = admin.auth();
export const messaging = admin.messaging();
export default admin;
