import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { sendNotification } from "./notifications";

// Initialize if not already done
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// Load Stripe credentials from Firebase Environment Configuration
// Set via: firebase functions:secrets:set STRIPE_SECRET_KEY
// Set via: firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
const STRIPE_SECRET_KEY = (process.env.STRIPE_SECRET_KEY || "").trim();
const STRIPE_WEBHOOK_SECRET = (process.env.STRIPE_WEBHOOK_SECRET || "").trim();
const PLATFORM_FEE_PERCENT = 15;

// Initialize Stripe SDK
const stripe = require("stripe")(STRIPE_SECRET_KEY);

// ─────────────────────────────────────────────────────────────
// stripeWebhook — HTTP Function (raw body for signature verification)
// ─────────────────────────────────────────────────────────────

/**
 * stripeWebhook — onRequest Function
 *
 * Handles Stripe webhook events securely.
 * Stripe requires the raw body for signature verification.
 *
 * Configure in Stripe Dashboard:
 *   Endpoint: https://<region>-<project>.cloudfunctions.net/stripeWebhook
 *   Events: checkout.session.completed, payment_intent.succeeded, payment_intent.payment_failed
 */
export const stripeWebhook = functions
  .runWith({
    secrets: ["STRIPE_SECRET_KEY", "STRIPE_WEBHOOK_SECRET"],
  })
  .https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }

  const sigHeader = req.headers["stripe-signature"];
  if (!sigHeader || typeof sigHeader !== "string") {
    res.status(400).send("Missing Stripe-Signature header");
    return;
  }

  let event;
  try {
    event = stripe.webhooks.constructEvent(
      req.rawBody,
      sigHeader,
      STRIPE_WEBHOOK_SECRET
    );
  } catch (err: any) {
    functions.logger.error(`Webhook signature verification failed: ${err.message}`);
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }

  // Handle events
  try {
    switch (event.type) {
      case "checkout.session.completed":
        await handleCheckoutSessionCompleted(event.data.object);
        break;

      case "payment_intent.succeeded":
        await handlePaymentIntentSucceeded(event.data.object);
        break;

      case "payment_intent.payment_failed":
        await handlePaymentIntentFailed(event.data.object);
        break;

      default:
        functions.logger.info(`Unhandled event type: ${event.type}`);
    }
  } catch (err: any) {
    functions.logger.error(`Error handling ${event.type}: ${err.message}`);
  }

  res.status(200).json({ status: "ok" });
});

// ─────────────────────────────────────────────────────────────
// Event Handlers
// ─────────────────────────────────────────────────────────────

async function handleCheckoutSessionCompleted(session: any) {
  const metadata = session.metadata || {};
  const userId = metadata.userId || "";
  const artistId = metadata.artistId || "";
  const paymentType = metadata.type || "";
  const performanceId = metadata.performanceId || "";
  const amountCents = session.amount_total || 0;
  const paymentIntentId =
    typeof session.payment_intent === "string" ? session.payment_intent : "";

  functions.logger.info(
    `checkout.session.completed: user=${userId} artist=${artistId} type=${paymentType} amount=${amountCents}`
  );

  // Skip if transaction already exists (created by success redirect)
  if (paymentIntentId) {
    const existing = await db
      .collection("transactions")
      .where("paymentIntentId", "==", paymentIntentId)
      .limit(1)
      .get();
    if (!existing.empty) {
      functions.logger.info("Transaction already exists, skipping");
      return;
    }
  }

  const platformFee = Math.floor(amountCents * (PLATFORM_FEE_PERCENT / 100));
  const netAmount = amountCents - platformFee;

  // Create transaction record
  const txRef = db.collection("transactions").doc();
  await txRef.set({
    userId,
    artistId,
    amount: amountCents,
    platformFee,
    netAmount,
    type: paymentType,
    performanceId,
    paymentIntentId,
    status: "succeeded",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Grant paid access to performance
  if (paymentType === "paid_access" && performanceId) {
    await db.collection("performances").doc(performanceId).update({
      paidUsers: admin.firestore.FieldValue.arrayUnion(userId),
    });
  }

  // Update artist earnings
  if (artistId) {
    await db.collection("users").doc(artistId).update({
      totalEarnings: admin.firestore.FieldValue.increment(netAmount),
      pendingPayout: admin.firestore.FieldValue.increment(netAmount),
    });
  }

  // Send payment notification to listener
  const amountDollars = (amountCents / 100).toFixed(2);
  await sendNotification(userId, {
    type: "payment_confirmed",
    title: "Payment Confirmed",
    body: `Your ${paymentType === "tip" ? "tip" : "access payment"} of $${amountDollars} was confirmed`,
    data: { performanceId, artistId, type: paymentType },
  });

  // Send tip received notification to artist
  if (paymentType === "tip" && artistId) {
    await sendNotification(artistId, {
      type: "tip_received",
      title: "Tip Received",
      body: `You received a $${amountDollars} tip`,
      data: { userId, performanceId },
    });
  }

  functions.logger.info(`Transaction created: ${txRef.id}`);
}

async function handlePaymentIntentSucceeded(intent: any) {
  const intentId = intent.id;
  const metadata = intent.metadata || {};

  functions.logger.info(`payment_intent.succeeded: pi=${intentId}`);

  // Check if transaction already exists
  const existing = await db
    .collection("transactions")
    .where("paymentIntentId", "==", intentId)
    .limit(1)
    .get();

  if (!existing.empty) {
    // Transaction exists — update status and grant access if needed
    const txData = existing.docs[0].data();
    await existing.docs[0].ref.update({ status: "succeeded" });
    const pId = txData.performanceId || metadata.performanceId;
    const pType = txData.type || metadata.type;
    const uId = txData.userId || metadata.userId;
    if (pType === "paid_access" && pId && uId) {
      await db.collection("performances").doc(pId).update({
        paidUsers: admin.firestore.FieldValue.arrayUnion(uId),
      });
    }
    functions.logger.info("Transaction status updated to succeeded");
    return;
  }

  // Native payment intent flow — create transaction now
  const userId = metadata.userId || "";
  const artistId = metadata.artistId || "";
  const paymentType = metadata.type || "";
  const performanceId = metadata.performanceId || "";
  const amountCents = intent.amount || 0;

  const platformFee = Math.floor(amountCents * (PLATFORM_FEE_PERCENT / 100));
  const netAmount = amountCents - platformFee;

  const txRef = db.collection("transactions").doc();
  await txRef.set({
    userId,
    artistId,
    amount: amountCents,
    platformFee,
    netAmount,
    type: paymentType,
    performanceId,
    paymentIntentId: intentId,
    status: "succeeded",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Grant paid access
  if (paymentType === "paid_access" && performanceId) {
    await db.collection("performances").doc(performanceId).update({
      paidUsers: admin.firestore.FieldValue.arrayUnion(userId),
    });
  }

  // Update artist earnings
  if (artistId) {
    await db.collection("users").doc(artistId).update({
      totalEarnings: admin.firestore.FieldValue.increment(netAmount),
      pendingPayout: admin.firestore.FieldValue.increment(netAmount),
    });
  }

  // Send payment notification to listener (native payment flow)
  const amountDollars = (amountCents / 100).toFixed(2);
  await sendNotification(userId, {
    type: "payment_confirmed",
    title: "Payment Confirmed",
    body: `Your ${paymentType === "tip" ? "tip" : "access payment"} of $${amountDollars} was confirmed`,
    data: { performanceId, artistId, type: paymentType },
  });

  // Send tip received notification to artist
  if (paymentType === "tip" && artistId) {
    await sendNotification(artistId, {
      type: "tip_received",
      title: "Tip Received",
      body: `You received a $${amountDollars} tip`,
      data: { userId, performanceId },
    });
  }

  functions.logger.info(`Transaction created: ${txRef.id}`);
}

async function handlePaymentIntentFailed(intent: any) {
  const intentId = intent.id;
  functions.logger.info(`payment_intent.payment_failed: pi=${intentId}`);

  const txs = await db
    .collection("transactions")
    .where("paymentIntentId", "==", intentId)
    .limit(1)
    .get();

  for (const tx of txs.docs) {
    await tx.ref.update({ status: "failed" });

    // Send payment failed notification to user
    const txData = tx.data();
    if (txData.userId) {
      await sendNotification(txData.userId, {
        type: "payment_failed",
        title: "Payment Failed",
        body: "Your payment could not be processed. Please try again.",
        data: {
          performanceId: txData.performanceId || "",
          artistId: txData.artistId || "",
        },
      });
    }
  }
}

// ─────────────────────────────────────────────────────────────
// createPaymentIntent — HTTPS Callable Function
// ─────────────────────────────────────────────────────────────

/**
 * createPaymentIntent — onCall Function
 *
 * Creates a Stripe PaymentIntent for native mobile payments.
 * Requires Firebase Authentication.
 *
 * Input:
 *   amount: number — Amount in dollars (e.g., 5.00)
 *   type: string — "tip" or "paid_access"
 *   artistId: string — Artist receiving payment
 *   performanceId?: string — Performance for paid_access
 *
 * Returns:
 *   { clientSecret, paymentIntentId }
 */
export const createPaymentIntent = functions
  .runWith({
    secrets: ["STRIPE_SECRET_KEY"],
  })
  .https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated."
    );
  }

  const { amount, type, artistId, performanceId } = data;

  if (!amount || !type || !artistId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "amount, type, and artistId are required."
    );
  }

  if (type !== "tip" && type !== "paid_access") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "type must be 'tip' or 'paid_access'."
    );
  }

  const amountCents = Math.floor(parseFloat(amount) * 100);
  const userId = context.auth.uid;

  try {
    const intent = await stripe.paymentIntents.create({
      amount: amountCents,
      currency: "usd",
      automatic_payment_methods: { enabled: true },
      metadata: {
        type,
        artistId,
        performanceId: performanceId || "",
        userId,
      },
    });

    return {
      clientSecret: intent.client_secret,
      paymentIntentId: intent.id,
    };
  } catch (err: any) {
    throw new functions.https.HttpsError("internal", err.message);
  }
});

// ─────────────────────────────────────────────────────────────
// createCheckoutSession — HTTPS Callable Function
// ─────────────────────────────────────────────────────────────

/**
 * createCheckoutSession — onCall Function
 *
 * Creates a Stripe Checkout Session for web payments.
 * Requires Firebase Authentication.
 *
 * Input:
 *   amount: number — Amount in dollars
 *   type: string — "tip" or "paid_access"
 *   artistId: string — Artist receiving payment
 *   performanceId?: string — Performance for paid_access
 *
 * Returns:
 *   { checkoutUrl, sessionId }
 */
export const createCheckoutSession = functions
  .runWith({
    secrets: ["STRIPE_SECRET_KEY"],
  })
  .https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated."
    );
  }

  const { amount, type, artistId, performanceId } = data;

  if (!amount || !type || !artistId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "amount, type, and artistId are required."
    );
  }

  const amountCents = Math.floor(parseFloat(amount) * 100);
  const userId = context.auth.uid;

  // Build success/cancel URLs using client-provided URLs or fallback to Cloud Functions
  const region = process.env.FUNCTION_REGION || "us-central1";
  const projectId = process.env.GCLOUD_PROJECT || "";
  const baseUrl = `https://${region}-${projectId}.cloudfunctions.net`;
  const successUrl = data.successUrl || `${baseUrl}/paymentSuccess?session_id={CHECKOUT_SESSION_ID}`;
  const cancelUrl = data.cancelUrl || `${baseUrl}/paymentCancelled`;

  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      line_items: [
        {
          price_data: {
            currency: "usd",
            product_data: {
              name: `Tip - ${type.replace(/_/g, " ").replace(/\b\w/g, (c: string) => c.toUpperCase())}`,
            },
            unit_amount: amountCents,
          },
          quantity: 1,
        },
      ],
      mode: "payment",
      success_url: successUrl,
      cancel_url: cancelUrl,
      metadata: {
        type,
        artistId,
        performanceId: performanceId || "",
        userId,
      },
    });

    return {
      checkoutUrl: session.url,
      sessionId: session.id,
    };
  } catch (err: any) {
    throw new functions.https.HttpsError("internal", err.message);
  }
});

// ─────────────────────────────────────────────────────────────
// confirmPayment — HTTPS Callable Function
// ─────────────────────────────────────────────────────────────

/**
 * confirmPayment — onCall Function
 *
 * Verifies with Stripe that a PaymentIntent or Checkout Session succeeded,
 * and immediately executes transaction creation and access granting in Firestore.
 * This guarantees synchronous access update even if webhooks are delayed.
 *
 * Input:
 *   paymentIntentId?: string
 *   sessionId?: string
 *
 * Returns:
 *   { success: boolean, status: string }
 */
export const confirmPayment = functions
  .runWith({
    secrets: ["STRIPE_SECRET_KEY"],
  })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated."
      );
    }

    const { paymentIntentId, sessionId } = data;

    try {
      if (paymentIntentId) {
        const intent = await stripe.paymentIntents.retrieve(paymentIntentId);
        if (intent.status === "succeeded") {
          await handlePaymentIntentSucceeded(intent);
          return { success: true, status: intent.status };
        }
        return { success: false, status: intent.status };
      }

      if (sessionId) {
        const session = await stripe.checkout.sessions.retrieve(sessionId);
        if (session.payment_status === "paid") {
          await handleCheckoutSessionCompleted(session);
          return { success: true, status: session.payment_status };
        }
        return { success: false, status: session.payment_status };
      }

      throw new functions.https.HttpsError(
        "invalid-argument",
        "paymentIntentId or sessionId is required."
      );
    } catch (err: any) {
      functions.logger.error(`Error in confirmPayment: ${err.message}`);
      throw new functions.https.HttpsError("internal", err.message);
    }
  });

// ─────────────────────────────────────────────────────────────
// checkAccess — HTTPS Callable Function
// ─────────────────────────────────────────────────────────────

/**
 * checkAccess — onCall Function
 *
 * Checks if a user has paid access to a performance.
 * Requires Firebase Authentication.
 *
 * Input:
 *   userId: string — User ID to check
 *   performanceId: string — Performance ID
 *
 * Returns:
 *   { hasAccess: boolean, isPaid: boolean, price: number }
 */
export const checkAccess = functions
  .runWith({
    secrets: ["STRIPE_SECRET_KEY"],
  })
  .https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated."
    );
  }

  const { userId, performanceId } = data;

  if (!userId || !performanceId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "userId and performanceId are required."
    );
  }

  try {
    const perfDoc = await db
      .collection("performances")
      .doc(performanceId)
      .get();

    if (!perfDoc.exists) {
      return {
        hasAccess: false,
        isPaid: false,
        price: 0,
      };
    }

    const perfData = perfDoc.data()!;
    const isPaid = perfData.isPaid === true;

    if (!isPaid) {
      // Free performance — everyone has access
      return {
        hasAccess: true,
        isPaid: false,
        price: 0,
      };
    }

    // Paid performance — check if user is in paidUsers array
    const paidUsers = perfData.paidUsers || [];
    const hasAccess = paidUsers.includes(userId);

    return {
      hasAccess,
      isPaid: true,
      price: perfData.ticketPrice ?? perfData.price ?? 9.99,
      ticketTier: perfData.ticketTier ?? null,
      ticketProductId: perfData.ticketProductId ?? null,
    };
  } catch (err: any) {
    throw new functions.https.HttpsError("internal", err.message);
  }
});

// ─────────────────────────────────────────────────────────────
// checkTipStatus — HTTPS Callable Function
// ─────────────────────────────────────────────────────────────

/**
 * checkTipStatus — onCall Function
 *
 * Checks if a user has tipped an artist.
 * Requires Firebase Authentication.
 *
 * Input:
 *   userId: string — User ID
 *   artistId: string — Artist ID
 *
 * Returns:
 *   { hasTipped: boolean, tipAmount: number }
 */
export const checkTipStatus = functions
  .runWith({
    secrets: ["STRIPE_SECRET_KEY"],
  })
  .https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated."
    );
  }

  const { userId, artistId } = data;

  if (!userId || !artistId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "userId and artistId are required."
    );
  }

  try {
    const tips = await db
      .collection("transactions")
      .where("userId", "==", userId)
      .where("artistId", "==", artistId)
      .where("type", "==", "tip")
      .where("status", "==", "succeeded")
      .get();

    const hasTipped = !tips.empty;
    const tipAmount = tips.docs.reduce(
      (sum, doc) => sum + (doc.data().amount || 0),
      0
    );

    return {
      hasTipped,
      tipAmount: tipAmount / 100, // Convert from cents to dollars
    };
  } catch (err: any) {
    throw new functions.https.HttpsError("internal", err.message);
  }
});

// ─────────────────────────────────────────────────────────────
// getTransactionHistory — HTTPS Callable Function
// ─────────────────────────────────────────────────────────────

/**
 * getTransactionHistory — onCall Function
 *
 * Retrieves transaction history for an artist.
 * Requires Firebase Authentication.
 *
 * Input:
 *   artistId: string — Artist ID to get transactions for
 *
 * Returns:
 *   { transactions: Transaction[], totalEarnings: number }
 */
export const getTransactionHistory = functions
  .runWith({
    secrets: ["STRIPE_SECRET_KEY"],
  })
  .https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated."
    );
  }

  const { artistId } = data;

  if (!artistId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "artistId is required."
    );
  }

  try {
    const transactions = await db
      .collection("transactions")
      .where("artistId", "==", artistId)
      .get();

    const sortedDocs = transactions.docs.sort((a, b) => {
      const aData = a.data();
      const bData = b.data();
      const aTime = aData.createdAt?.toMillis?.() || (aData.createdAt?._seconds ? aData.createdAt._seconds * 1000 : 0);
      const bTime = bData.createdAt?.toMillis?.() || (bData.createdAt?._seconds ? bData.createdAt._seconds * 1000 : 0);
      return bTime - aTime;
    }).slice(0, 100);

    const txList = sortedDocs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    const grossEarnings = txList.reduce((sum: number, tx: any) => sum + (tx.amount || 0), 0);
    const storeFee = txList.reduce((sum: number, tx: any) => sum + (tx.storeFee || 0), 0);
    const platformFee = txList.reduce((sum: number, tx: any) => sum + (tx.platformFee || 0), 0);
    const netEarnings = txList.reduce((sum: number, tx: any) => sum + (tx.netAmount || 0), 0);

    return {
      transactions: txList,
      grossEarnings,
      storeFee,
      platformFee,
      netEarnings,
    };
  } catch (err: any) {
    throw new functions.https.HttpsError("internal", err.message);
  }
});

// ─────────────────────────────────────────────────────────────
// createConnectAccount — HTTPS Callable Function
// ─────────────────────────────────────────────────────────────

/**
 * createConnectAccount — onCall Function
 *
 * Creates a Stripe Express connected account for an artist and returns an onboarding link.
 * Requires Firebase Authentication.
 */
export const createConnectAccount = functions
  .runWith({ secrets: ["STRIPE_SECRET_KEY"] })
  .https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");

  const { artistId } = data;
  if (!artistId) throw new functions.https.HttpsError("invalid-argument", "artistId is required.");
  if (context.auth.uid !== artistId) throw new functions.https.HttpsError("permission-denied", "Can only create connect account for self.");

  try {
    const userDocRef = db.collection("users").doc(artistId);
    const userDoc = await userDocRef.get();
    if (!userDoc.exists) throw new functions.https.HttpsError("not-found", "User not found.");
    
    let accountId = userDoc.data()?.stripeAccountId;

    // Create connected account if it doesn't exist
    if (!accountId) {
      const account = await stripe.accounts.create({
        type: 'express',
        country: 'US',
        email: userDoc.data()?.email,
        capabilities: {
          transfers: { requested: true },
        },
        business_type: 'individual',
      });
      accountId = account.id;
      await userDocRef.update({
        stripeAccountId: accountId,
        stripeOnboardingComplete: false,
      });
    }

    // Create account link for onboarding
    const accountLink = await stripe.accountLinks.create({
      account: accountId,
      refresh_url: `https://vibeswipe.app/connect/refresh`, // Fallback/dummy deep links
      return_url: `https://vibeswipe.app/connect/return`,
      type: 'account_onboarding',
    });

    return {
      accountId,
      onboardingUrl: accountLink.url,
    };
  } catch (error: any) {
    functions.logger.error("Error creating connect account:", error);
    throw new functions.https.HttpsError("internal", error.message || "An error occurred");
  }
});

// ─────────────────────────────────────────────────────────────
// getConnectAccountStatus — HTTPS Callable Function
// ─────────────────────────────────────────────────────────────

/**
 * getConnectAccountStatus — onCall Function
 *
 * Checks if the artist's Stripe Connect account is fully onboarded and payouts are enabled.
 */
export const getConnectAccountStatus = functions
  .runWith({ secrets: ["STRIPE_SECRET_KEY"] })
  .https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");

  const { artistId } = data;
  if (!artistId) throw new functions.https.HttpsError("invalid-argument", "artistId is required.");

  try {
    const userDoc = await db.collection("users").doc(artistId).get();
    const accountId = userDoc.data()?.stripeAccountId;

    if (!accountId) {
      return { connected: false, payoutsEnabled: false };
    }

    const account = await stripe.accounts.retrieve(accountId);
    const payoutsEnabled = account.payouts_enabled;
    const detailsSubmitted = account.details_submitted;

    // Update Firestore if changed
    if (userDoc.data()?.stripeOnboardingComplete !== payoutsEnabled) {
      await db.collection("users").doc(artistId).update({
        stripeOnboardingComplete: payoutsEnabled,
      });
    }

    return {
      connected: true,
      payoutsEnabled,
      detailsSubmitted,
      accountId,
    };
  } catch (err: any) {
    throw new functions.https.HttpsError("internal", err.message);
  }
});

// ─────────────────────────────────────────────────────────────
// requestPayout — HTTPS Callable Function
// ─────────────────────────────────────────────────────────────

/**
 * requestPayout — onCall Function
 *
 * Initiates a Stripe Transfer to move the artist's pending payout balance
 * to their Stripe Connect account.
 */
export const requestPayout = functions
  .runWith({ secrets: ["STRIPE_SECRET_KEY"] })
  .https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");

  const { artistId, amount } = data; // amount in dollars
  if (!artistId || !amount) throw new functions.https.HttpsError("invalid-argument", "artistId and amount are required.");
  if (context.auth.uid !== artistId) throw new functions.https.HttpsError("permission-denied", "Can only request payout for self.");

  const amountCents = Math.floor(parseFloat(amount) * 100);
  if (amountCents < 1000) throw new functions.https.HttpsError("invalid-argument", "Minimum withdrawal amount is $10.");

  try {
    return await db.runTransaction(async (t) => {
      const userRef = db.collection("users").doc(artistId);
      const userDoc = await t.get(userRef);
      
      if (!userDoc.exists) throw new functions.https.HttpsError("not-found", "User not found.");
      
      const accountId = userDoc.data()?.stripeAccountId;
      const payoutsEnabled = userDoc.data()?.stripeOnboardingComplete;
      const pendingPayoutCents = userDoc.data()?.pendingPayout || 0;

      if (!accountId || !payoutsEnabled) {
        throw new functions.https.HttpsError("failed-precondition", "Stripe Connect account not set up or payouts disabled.");
      }

      if (pendingPayoutCents < amountCents) {
        throw new functions.https.HttpsError("failed-precondition", "Insufficient pending payout balance.");
      }

      // Perform Stripe Transfer
      // This moves funds from platform balance to the connected account
      const transfer = await stripe.transfers.create({
        amount: amountCents,
        currency: 'usd',
        destination: accountId,
        description: `VibeSwipe Artist Payout`,
      });

      // Deduct from pending payout
      t.update(userRef, {
        pendingPayout: admin.firestore.FieldValue.increment(-amountCents),
      });

      // Record payout transaction
      const payoutRef = db.collection("payouts").doc();
      t.set(payoutRef, {
        artistId,
        amount: amountCents,
        stripeTransferId: transfer.id,
        destinationAccount: accountId,
        status: "paid",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true, payoutId: payoutRef.id, transferId: transfer.id };
    });
  } catch (err: any) {
    throw new functions.https.HttpsError("internal", err.message);
  }
});

// ─────────────────────────────────────────────────────────────
// stripeConnectWebhook — HTTP Function
// ─────────────────────────────────────────────────────────────

/**
 * stripeConnectWebhook — onRequest Function
 *
 * Listens for Connect account updates (e.g. account.updated) to sync onboarding status.
 */
export const stripeConnectWebhook = functions
  .runWith({ secrets: ["STRIPE_SECRET_KEY", "STRIPE_WEBHOOK_SECRET"] })
  .https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }

  const sigHeader = req.headers["stripe-signature"];
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET || "";

  if (!sigHeader || typeof sigHeader !== "string") {
    res.status(400).send("Missing Stripe-Signature header");
    return;
  }

  let event;
  try {
    event = stripe.webhooks.constructEvent(req.rawBody, sigHeader, webhookSecret);
  } catch (err: any) {
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }

  try {
    if (event.type === "account.updated") {
      const account = event.data.object;
      const accountId = account.id;
      const payoutsEnabled = account.payouts_enabled;

      const usersSnapshot = await db.collection("users").where("stripeAccountId", "==", accountId).limit(1).get();
      if (!usersSnapshot.empty) {
        await usersSnapshot.docs[0].ref.update({
          stripeOnboardingComplete: payoutsEnabled,
        });
      }
    }
  } catch (err: any) {
    functions.logger.error(`Error handling connect webhook: ${err.message}`);
  }

  res.status(200).json({ status: "ok" });
});

// ─────────────────────────────────────────────────────────────
// paymentSuccess & paymentCancelled — HTML Redirect Endpoints
// ─────────────────────────────────────────────────────────────

export const paymentSuccess = functions
  .runWith({ secrets: ["STRIPE_SECRET_KEY"] })
  .https.onRequest(async (req, res) => {
    const sessionId = req.query.session_id as string;
    if (sessionId) {
      try {
        const session = await stripe.checkout.sessions.retrieve(sessionId);
        if (session.payment_status === "paid") {
          await handleCheckoutSessionCompleted(session);
        }
      } catch (e: any) {
        functions.logger.error("Error confirming session in paymentSuccess:", e);
      }
    }

    res.setHeader("Content-Type", "text/html");
    res.status(200).send(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>Payment Successful</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #0d1117; color: #ffffff; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
          .card { background: #161b22; border: 1px solid #30363d; padding: 40px; border-radius: 16px; text-align: center; max-width: 400px; box-shadow: 0 8px 24px rgba(0,0,0,0.5); }
          .icon { font-size: 64px; color: #2ea043; margin-bottom: 16px; }
          h1 { margin: 0 0 12px 0; font-size: 24px; }
          p { color: #8b949e; font-size: 15px; line-height: 1.5; margin-bottom: 24px; }
        </style>
      </head>
      <body>
        <div class="card">
          <div class="icon">✓</div>
          <h1>Payment Successful!</h1>
          <p>Thank you for your payment. Returning to VibeSwipe...</p>
        </div>
        <script>
          setTimeout(function() {
            if (window.opener) {
              try { window.opener.postMessage('payment_complete', '*'); } catch (e) {}
            }
            window.close();
          }, 1500);
        </script>
      </body>
    </html>
  `);
});

export const paymentCancelled = functions.https.onRequest(async (req, res) => {
  res.setHeader("Content-Type", "text/html");
  res.status(200).send(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>Payment Cancelled</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #0d1117; color: #ffffff; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
          .card { background: #161b22; border: 1px solid #30363d; padding: 40px; border-radius: 16px; text-align: center; max-width: 400px; box-shadow: 0 8px 24px rgba(0,0,0,0.5); }
          .icon { font-size: 64px; color: #f85149; margin-bottom: 16px; }
          h1 { margin: 0 0 12px 0; font-size: 24px; }
          p { color: #8b949e; font-size: 15px; line-height: 1.5; margin-bottom: 24px; }
        </style>
      </head>
      <body>
        <div class="card">
          <div class="icon">✕</div>
          <h1>Payment Cancelled</h1>
          <p>The payment process was cancelled. You may close this tab and return to VibeSwipe.</p>
        </div>
      </body>
    </html>
  `);
});
