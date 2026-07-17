import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'python_api_service.dart';

class StripeService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  Future<Map<String, String>> _headers() async {
    final user = _auth.currentUser;
    String? token;
    if (user != null) {
      token = await user.getIdToken();
    }
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

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

    final response = await http.post(
      Uri.parse('${PythonApiService.baseUrl}/stripe/create-checkout-session'),
      headers: await _headers(),
      body: jsonEncode({
        'amount': amount,
        'type': type,
        'artistId': artistId,
        'performanceId': performanceId,
        'userId': userId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create checkout session: ${response.body}');
    }

    final data = jsonDecode(response.body);
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

      // Call confirm-payment immediately on native to write the transaction
      final userId = _userId;
      if (userId != null) {
        try {
          await confirmPayment(
            paymentIntentId: paymentIntentId,
            userId: userId,
            artistId: artistId,
            amount: amount,
            type: type,
            performanceId: performanceId,
          );
        } catch (confirmError) {
          debugPrint('[Stripe] confirmPayment error (non-fatal, webhook fallback): $confirmError');
        }
      }
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
    final response = await http.post(
      Uri.parse('${PythonApiService.baseUrl}/stripe/create-payment-intent'),
      headers: await _headers(),
      body: jsonEncode({
        'amount': amount,
        'type': type,
        'artistId': artistId,
        'performanceId': performanceId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create payment intent: ${response.body}');
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  // ─────────────────────────────────────────────────────────
  // Access & Tip Checks
  // ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> checkAccess({
    required String userId,
    required String performanceId,
  }) async {
    final response = await http.get(
      Uri.parse('${PythonApiService.baseUrl}/stripe/check-access/$userId/$performanceId'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to check access: ${response.body}');
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  Future<bool> checkTipStatus({
    required String userId,
    required String artistId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${PythonApiService.baseUrl}/stripe/check-tip-status/$userId/$artistId'),
        headers: await _headers(),
      );

      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body);
      return data['hasTipped'] == true;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // Transaction History
  // ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTransactionHistory(String artistId) async {
    final response = await http.get(
      Uri.parse('${PythonApiService.baseUrl}/stripe/transaction-history/$artistId'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get transaction history: ${response.body}');
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  // ─────────────────────────────────────────────────────────
  // Checkout Completion
  // ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> checkoutComplete(String sessionId) async {
    final response = await http.post(
      Uri.parse('${PythonApiService.baseUrl}/stripe/checkout-complete'),
      headers: await _headers(),
      body: jsonEncode({'sessionId': sessionId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to complete checkout: ${response.body}');
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentId,
    required String userId,
    required String artistId,
    required double amount,
    required String type,
    String? performanceId,
  }) async {
    final response = await http.post(
      Uri.parse('${PythonApiService.baseUrl}/stripe/confirm-payment'),
      headers: await _headers(),
      body: jsonEncode({
        'paymentIntentId': paymentIntentId,
        'userId': userId,
        'artistId': artistId,
        'amount': amount,
        'type': type,
        'performanceId': performanceId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to confirm payment: ${response.body}');
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }
}
