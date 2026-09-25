"use strict";
// Firebase Cloud Functions — VibeSwipe
//
// This file exports all Cloud Functions.
// Functions are organized by service in separate files.
//
// Deployment: firebase deploy --only functions
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyInAppPurchase = exports.onPerformanceStatusChanged = exports.onPerformanceLike = exports.onPostLike = exports.onPostComment = exports.onNewFollower = exports.paymentCancelled = exports.paymentSuccess = exports.stripeConnectWebhook = exports.requestPayout = exports.getConnectAccountStatus = exports.createConnectAccount = exports.getTransactionHistory = exports.checkTipStatus = exports.checkAccess = exports.confirmPayment = exports.createCheckoutSession = exports.createPaymentIntent = exports.stripeWebhook = exports.generateAgoraToken = void 0;
var agora_1 = require("./agora");
Object.defineProperty(exports, "generateAgoraToken", { enumerable: true, get: function () { return agora_1.generateAgoraToken; } });
var stripe_1 = require("./stripe");
Object.defineProperty(exports, "stripeWebhook", { enumerable: true, get: function () { return stripe_1.stripeWebhook; } });
Object.defineProperty(exports, "createPaymentIntent", { enumerable: true, get: function () { return stripe_1.createPaymentIntent; } });
Object.defineProperty(exports, "createCheckoutSession", { enumerable: true, get: function () { return stripe_1.createCheckoutSession; } });
Object.defineProperty(exports, "confirmPayment", { enumerable: true, get: function () { return stripe_1.confirmPayment; } });
Object.defineProperty(exports, "checkAccess", { enumerable: true, get: function () { return stripe_1.checkAccess; } });
Object.defineProperty(exports, "checkTipStatus", { enumerable: true, get: function () { return stripe_1.checkTipStatus; } });
Object.defineProperty(exports, "getTransactionHistory", { enumerable: true, get: function () { return stripe_1.getTransactionHistory; } });
Object.defineProperty(exports, "createConnectAccount", { enumerable: true, get: function () { return stripe_1.createConnectAccount; } });
Object.defineProperty(exports, "getConnectAccountStatus", { enumerable: true, get: function () { return stripe_1.getConnectAccountStatus; } });
Object.defineProperty(exports, "requestPayout", { enumerable: true, get: function () { return stripe_1.requestPayout; } });
Object.defineProperty(exports, "stripeConnectWebhook", { enumerable: true, get: function () { return stripe_1.stripeConnectWebhook; } });
Object.defineProperty(exports, "paymentSuccess", { enumerable: true, get: function () { return stripe_1.paymentSuccess; } });
Object.defineProperty(exports, "paymentCancelled", { enumerable: true, get: function () { return stripe_1.paymentCancelled; } });
var notification_triggers_1 = require("./notification_triggers");
Object.defineProperty(exports, "onNewFollower", { enumerable: true, get: function () { return notification_triggers_1.onNewFollower; } });
Object.defineProperty(exports, "onPostComment", { enumerable: true, get: function () { return notification_triggers_1.onPostComment; } });
Object.defineProperty(exports, "onPostLike", { enumerable: true, get: function () { return notification_triggers_1.onPostLike; } });
Object.defineProperty(exports, "onPerformanceLike", { enumerable: true, get: function () { return notification_triggers_1.onPerformanceLike; } });
Object.defineProperty(exports, "onPerformanceStatusChanged", { enumerable: true, get: function () { return notification_triggers_1.onPerformanceStatusChanged; } });
var iap_1 = require("./iap");
Object.defineProperty(exports, "verifyInAppPurchase", { enumerable: true, get: function () { return iap_1.verifyInAppPurchase; } });
//# sourceMappingURL=index.js.map