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
exports.verifyInAppPurchase = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const firebase_admin_1 = require("./firebase-admin");
const notifications_1 = require("./notifications");
const PLATFORM_FEE_PERCENT = 10;
const STORE_FEE_PERCENT = 15;
/**
 * verifyInAppPurchase — onCall Function
 *
 * Securely fulfills an Apple StoreKit or Google Play In-App Purchase:
 * 1. Verifies authentication
 * 2. Deduplicates transaction by transactionId
 * 3. Grants live stream access (paidUsers arrayUnion) if ticket purchase
 * 4. Records transaction in `transactions` collection
 * 5. Increments artist earnings in `users/{artistId}`
 * 6. Sends push notifications to listener and artist
 */
exports.verifyInAppPurchase = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
    }
    const userId = context.auth.uid;
    const { productId, type, // 'ticket' | 'superchat' | 'paid_access' | 'tip'
    performanceId, artistId, amount, badge, // 'bronze' | 'silver' | 'gold' | 'platinum'
    transactionId, source, // 'apple_iap' | 'google_play'
    message, } = data;
    if (!productId || !amount) {
        throw new functions.https.HttpsError("invalid-argument", "productId and amount are required.");
    }
    const numAmount = parseFloat(amount);
    if (isNaN(numAmount) || numAmount <= 0) {
        throw new functions.https.HttpsError("invalid-argument", "Valid amount is required.");
    }
    const amountCents = Math.floor(numAmount * 100);
    const storeSource = source === "google_play" ? "google_play" : "apple_iap";
    const storeFee = Math.floor(amountCents * (STORE_FEE_PERCENT / 100));
    const platformFee = Math.floor(amountCents * (PLATFORM_FEE_PERCENT / 100));
    const netAmount = amountCents - storeFee - platformFee;
    const resolvedType = type === "ticket" || type === "paid_access" ? "paid_access" : "tip";
    functions.logger.info(`verifyInAppPurchase: user=${userId} artist=${artistId} type=${resolvedType} prod=${productId} tx=${transactionId}`);
    // Deduplication check if transactionId provided
    if (transactionId) {
        const existing = await firebase_admin_1.db
            .collection("transactions")
            .where("transactionId", "==", transactionId)
            .limit(1)
            .get();
        if (!existing.empty) {
            functions.logger.info(`Transaction ${transactionId} already processed, returning success.`);
            return {
                success: true,
                alreadyProcessed: true,
                transactionId,
            };
        }
    }
    // 1. If ticket purchase, grant access to performance
    if (resolvedType === "paid_access" && performanceId) {
        await firebase_admin_1.db
            .collection("performances")
            .doc(performanceId)
            .update({
            paidUsers: admin.firestore.FieldValue.arrayUnion(userId),
        });
    }
    // 2. Create transaction record
    const txRef = firebase_admin_1.db.collection("transactions").doc();
    const finalTxId = transactionId || txRef.id;
    await txRef.set({
        userId,
        artistId: artistId || "",
        amount: amountCents,
        storeFee,
        platformFee,
        netAmount,
        type: resolvedType,
        performanceId: performanceId || "",
        productId,
        purchaseSource: storeSource,
        transactionId: finalTxId,
        badge: badge || null,
        message: message || null,
        status: "succeeded",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // 3. Update artist earnings
    if (artistId) {
        try {
            await firebase_admin_1.db
                .collection("users")
                .doc(artistId)
                .update({
                totalEarnings: admin.firestore.FieldValue.increment(netAmount),
                pendingPayout: admin.firestore.FieldValue.increment(netAmount),
            });
        }
        catch (err) {
            functions.logger.warn(`Could not increment artist earnings for ${artistId}: ${err.message}`);
        }
    }
    // 4. Send notifications
    const amountDollars = numAmount.toFixed(2);
    try {
        // Notification to listener
        await (0, notifications_1.sendNotification)(userId, {
            type: "payment_confirmed",
            title: "Payment Confirmed",
            body: `Your ${resolvedType === "tip" ? "tip" : "ticket pass"} of $${amountDollars} was confirmed`,
            data: {
                performanceId: performanceId || "",
                artistId: artistId || "",
                type: resolvedType,
            },
        });
        // Notification to artist
        if (artistId) {
            await (0, notifications_1.sendNotification)(artistId, {
                type: "tip_received",
                title: resolvedType === "tip" ? "Tip Received!" : "Ticket Sold!",
                body: resolvedType === "tip"
                    ? `You received a $${amountDollars} tip (${badge || "Super Chat"})`
                    : `A fan purchased a $${amountDollars} ticket to your stream!`,
                data: {
                    userId,
                    performanceId: performanceId || "",
                    type: resolvedType,
                },
            });
        }
    }
    catch (notifErr) {
        functions.logger.warn(`Failed sending notification: ${notifErr.message}`);
    }
    return {
        success: true,
        transactionId: finalTxId,
        performanceId,
        hasAccess: true,
    };
});
//# sourceMappingURL=iap.js.map