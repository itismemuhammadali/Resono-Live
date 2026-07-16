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
exports.generateAgoraToken = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
// Initialize if not already done
if (!admin.apps.length) {
    admin.initializeApp();
}
const db = admin.firestore();
// Load Agora credentials from Firebase Environment Configuration
// Set via: firebase functions:secrets:set AGORA_APP_ID
// Set via: firebase functions:secrets:set AGORA_APP_CERTIFICATE
const AGORA_APP_ID = process.env.AGORA_APP_ID || "";
const AGORA_APP_CERTIFICATE = process.env.AGORA_APP_CERTIFICATE || "";
/**
 * generateAgoraToken — HTTPS Callable Function
 *
 * Generates a secure Agora RTC token for live streaming.
 * Requires Firebase Authentication.
 *
 * Input:
 *   channelName: string — Agora channel name
 *   uid: number — User ID (0 for auto-assign)
 *   role: string — "publisher" or "subscriber"
 *   expireTime: number — Token expiry in seconds (default 3600)
 *   performanceId?: string — Required for subscriber role on paid performances
 *
 * Returns:
 *   { token, channelName, uid, expiresIn }
 */
exports.generateAgoraToken = functions
    .runWith({
    secrets: ["AGORA_APP_ID", "AGORA_APP_CERTIFICATE"],
})
    .https.onCall(async (data, context) => {
    // 1. Verify authentication
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be authenticated to generate an Agora token.");
    }
    // 2. Validate Agora credentials
    if (!AGORA_APP_ID || !AGORA_APP_CERTIFICATE) {
        throw new functions.https.HttpsError("failed-precondition", "Agora credentials not configured. Set AGORA_APP_ID and AGORA_APP_CERTIFICATE.");
    }
    const { channelName = "live-stream-test", uid = 0, role = "publisher", expireTime = 3600, performanceId, } = data;
    // 3. For subscriber role, verify payment access if performance is paid
    if (role === "subscriber" && performanceId) {
        const perfDoc = await db.collection("performances").doc(performanceId).get();
        if (perfDoc.exists) {
            const perfData = perfDoc.data();
            if (perfData.isPaid === true) {
                const paidUsers = perfData.paidUsers || [];
                if (!paidUsers.includes(context.auth.uid)) {
                    throw new functions.https.HttpsError("permission-denied", "Payment required to access this stream.");
                }
            }
        }
    }
    // 4. Generate the Agora RTC token
    // Use agora-token package
    const { RtcTokenBuilder, RtcRole } = require("agora-token");
    const agoraRole = role === "publisher" ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER;
    const privilegeExpiration = Math.floor(Date.now() / 1000) + expireTime;
    const token = RtcTokenBuilder.buildTokenWithUid(AGORA_APP_ID, AGORA_APP_CERTIFICATE, channelName, uid, agoraRole, privilegeExpiration);
    functions.logger.info(`Agora token generated: channel=${channelName} uid=${uid} role=${role} expires_in=${expireTime}s`);
    return {
        token,
        channelName,
        uid,
        expiresIn: expireTime,
    };
});
//# sourceMappingURL=agora.js.map