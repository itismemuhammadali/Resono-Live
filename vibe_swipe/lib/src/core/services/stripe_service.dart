import 'dart:io' show Platform;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:url_launcher/url_launcher.dart';

class StripeService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

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

    final callable = _functions.httpsCallable('createCheckoutSession');
    final response = await callable.call({
      'amount': amount,
      'type': type,
      'artistId': artistId,
      'performanceId': performanceId,
      'userId': userId,
    });

    return response.data['checkoutUrl'] as String;
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
    if (!kIsWeb && Platform.isIOS) {
      return false;
    }
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
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
          webOnlyWindowName: '_self',
        );
      }
      return false;
    } catch (e) {
      debugPrint('[Stripe] Web payment error: $e');
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
      final paymentIntentId = paymentIntentData['paymentIntentId'];
      if (clientSecret == null || paymentIntentId == null) return false;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'VibeSwipe',
          style: ThemeMode.dark,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // Immediately confirm with Cloud Functions backend to update Firestore synchronously
      if (paymentIntentId is String) {
        await confirmPayment(paymentIntentId: paymentIntentId);
      }

      return true;
    } catch (e) {
      debugPrint('[Stripe] Native payment error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // Payment Intent & Confirmation
  // ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> confirmPayment({
    String? paymentIntentId,
    String? sessionId,
  }) async {
    try {
      final callable = _functions.httpsCallable('confirmPayment');
      final response = await callable.call({
        if (paymentIntentId != null) 'paymentIntentId': paymentIntentId,
        if (sessionId != null) 'sessionId': sessionId,
      });

      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      debugPrint('[Stripe] Error confirming payment: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String type,
    required String artistId,
    String? performanceId,
  }) async {
    final callable = _functions.httpsCallable('createPaymentIntent');
    final response = await callable.call({
      'amount': amount,
      'type': type,
      'artistId': artistId,
      'performanceId': performanceId,
    });

    return Map<String, dynamic>.from(response.data);
  }

  // ─────────────────────────────────────────────────────────
  // Access & Tip Checks
  // ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> checkAccess({
    required String userId,
    required String performanceId,
  }) async {
    final callable = _functions.httpsCallable('checkAccess');
    final response = await callable.call({
      'userId': userId,
      'performanceId': performanceId,
    });

    return Map<String, dynamic>.from(response.data);
  }

  Future<bool> checkTipStatus({
    required String userId,
    required String artistId,
  }) async {
    try {
      final callable = _functions.httpsCallable('checkTipStatus');
      final response = await callable.call({
        'userId': userId,
        'artistId': artistId,
      });

      return response.data['hasTipped'] == true;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // Transaction History
  // ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTransactionHistory(String artistId) async {
    final callable = _functions.httpsCallable('getTransactionHistory');
    final response = await callable.call({
      'artistId': artistId,
    });

    return Map<String, dynamic>.from(response.data);
  }

  // ─────────────────────────────────────────────────────────
  // Stripe Connect & Payouts
  // ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createConnectAccount(String artistId) async {
    final callable = _functions.httpsCallable('createConnectAccount');
    final response = await callable.call({
      'artistId': artistId,
    });

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> getConnectAccountStatus(String artistId) async {
    final callable = _functions.httpsCallable('getConnectAccountStatus');
    final response = await callable.call({
      'artistId': artistId,
    });

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> requestPayout({
    required String artistId,
    required double amount,
  }) async {
    final callable = _functions.httpsCallable('requestPayout');
    final response = await callable.call({
      'artistId': artistId,
      'amount': amount,
    });

    return Map<String, dynamic>.from(response.data);
  }
}
