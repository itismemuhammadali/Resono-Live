// Firebase Cloud Functions — VibeSwipe
//
// This file exports all Cloud Functions.
// Functions are organized by service in separate files.
//
// Deployment: firebase deploy --only functions

export { generateAgoraToken } from "./agora";
export {
  stripeWebhook,
  createPaymentIntent,
  createCheckoutSession,
  confirmPayment,
  checkAccess,
  checkTipStatus,
  getTransactionHistory,
  createConnectAccount,
  getConnectAccountStatus,
  requestPayout,
  stripeConnectWebhook,
  paymentSuccess,
  paymentCancelled,
} from "./stripe";
export {
  onNewFollower,
  onPostComment,
  onPostLike,
  onPerformanceLike,
  onPerformanceStatusChanged,
} from "./notification_triggers";
export { verifyInAppPurchase } from "./iap";
