import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class StripeService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // ─────────────────────────────────────────────────────────
  // Checkout Session (Web Flow)
  // ─────────────────────────────────────────────────────────

  Future<String> createCheckoutSession({
    required double amount,
    required String type,
    required String artistId,
    String? performanceId,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('Not authenticated');

    final callable = FirebaseFunctions.instance.httpsCallable('createCheckoutSession');
    final result = await callable.call({
      'amount': amount,
      'type': type,
      'artistId': artistId,
      'performanceId': performanceId,
    });

    final data = result.data as Map<String, dynamic>;
    return data['checkoutUrl'] as String;
  }

  // ─────────────────────────────────────────────────────────
  // Process Payment (Routes to Web or Native)
  // ─────────────────────────────────────────────────────────

  Future<bool> processPayment({
    required double amount,
    required String type,
    required String artistId,
    String? performanceId,
  }) async {
    if (kIsWeb) {
      return _processPaymentWeb(
        amount: amount,
        type: type,
        artistId: artistId,
        performanceId: performanceId,
      );
    }
    return _processPaymentNative(
      amount: amount,
      type: type,
      artistId: artistId,
      performanceId: performanceId,
    );
  }

  Future<bool> _processPaymentWeb({
    required double amount,
    required String type,
    required String artistId,
    String? performanceId,
  }) async {
    try {
      final checkoutUrl = await createCheckoutSession(
        amount: amount,
        type: type,
        artistId: artistId,
        performanceId: performanceId,
      );

      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
      // Don't return true — payment completion is confirmed via webhook.
      // The caller should poll checkAccess() to detect when access is granted.
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _processPaymentNative({
    required double amount,
    required String type,
    required String artistId,
    String? performanceId,
  }) async {
    try {
      final paymentIntentData = await createPaymentIntent(
        amount: amount,
        type: type,
        artistId: artistId,
        performanceId: performanceId,
      );

      final clientSecret = paymentIntentData['clientSecret'];
      if (clientSecret == null) return false;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'VibeSwipe',
          style: ThemeMode.dark,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // The webhook (payment_intent.succeeded) already writes the Firestore
      // transaction and updates the artist earnings, so there is nothing to do
      // here. Simply return true to signal the sheet completed without error.
      return true;
    } catch (e) {
      debugPrint('[Stripe] Native payment error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // Payment Intent (Native Flow)
  // ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String type,
    required String artistId,
    String? performanceId,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable('createPaymentIntent');
    final result = await callable.call({
      'amount': amount,
      'type': type,
      'artistId': artistId,
      'performanceId': performanceId,
    });

    return Map<String, dynamic>.from(result.data as Map);
  }

  // ─────────────────────────────────────────────────────────
  // Access & Tip Checks
  // ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> checkAccess({
    required String userId,
    required String performanceId,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable('checkAccess');
    final result = await callable.call({
      'userId': userId,
      'performanceId': performanceId,
    });

    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<bool> checkTipStatus({
    required String userId,
    required String artistId,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('checkTipStatus');
      final result = await callable.call({
        'userId': userId,
        'artistId': artistId,
      });

      final data = result.data as Map<String, dynamic>;
      return data['hasTipped'] == true;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // Transaction History
  // ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTransactionHistory(String artistId) async {
    final callable = FirebaseFunctions.instance.httpsCallable('getTransactionHistory');
    final result = await callable.call({
      'artistId': artistId,
    });

    return Map<String, dynamic>.from(result.data as Map);
  }

  // ─────────────────────────────────────────────────────────
  // Checkout Completion
  // ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> checkoutComplete(String sessionId) async {
    final callable = FirebaseFunctions.instance.httpsCallable('checkoutComplete');
    final result = await callable.call({
      'sessionId': sessionId,
    });

    return Map<String, dynamic>.from(result.data as Map);
  }
}
