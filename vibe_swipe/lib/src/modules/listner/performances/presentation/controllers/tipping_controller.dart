import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class TipRecord {
  const TipRecord({
    required this.amount,
    required this.artistName,
    required this.timestamp,
  });

  final double amount;
  final String artistName;
  final DateTime timestamp;
}

final tippingControllerProvider =
    ChangeNotifierProvider.autoDispose<TippingController>(
      (ref) => TippingController(),
    );

class TippingController extends ChangeNotifier with Buffers {
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  bool _hasPaid = false;
  bool get hasPaid => _hasPaid;

  String? _paymentError;
  String? get paymentError => _paymentError;

  final List<TipRecord> _tipHistory = [];
  List<TipRecord> get tipHistory => List.unmodifiable(_tipHistory);

  double get totalTipped => _tipHistory.fold(0.0, (sum, t) => sum + t.amount);

  final _stripeService = StripeService();

  Future<bool> processTip({
    required double amount,
    required String artistId,
    required String artistName,
  }) async {
    if (!kIsWeb && Platform.isIOS) return false;
    if (_isProcessing) return false;
    _isProcessing = true;
    _paymentError = null;
    notifyListeners();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return false;

      final success = await _stripeService.processPayment(
        amount: amount,
        type: 'tip',
        artistId: artistId,
      );

      if (success) {
        _tipHistory.insert(
          0,
          TipRecord(
            amount: amount,
            artistName: artistName,
            timestamp: DateTime.now(),
          ),
        );
        notifyListeners();
        return true;
      }

      // Web: processPayment returns false (checkout opened in browser).
      // Poll checkTipStatus until the webhook confirms payment.
      if (kIsWeb) {
        for (var i = 0; i < 30; i++) {
          await Future.delayed(const Duration(seconds: 2));
          try {
            final confirmed = await _stripeService.checkTipStatus(
              userId: userId,
              artistId: artistId,
            );
            if (confirmed) {
              _tipHistory.insert(
                0,
                TipRecord(
                  amount: amount,
                  artistName: artistName,
                  timestamp: DateTime.now(),
                ),
              );
              notifyListeners();
              return true;
            }
          } catch (_) {}
        }
      }

      return false;
    } catch (e) {
      _paymentError = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<bool> unlockPerformance({
    required double amount,
    required String artistId,
    required String performanceId,
  }) async {
    if (!kIsWeb && Platform.isIOS) {
      _hasPaid = true;
      notifyListeners();
      return true;
    }
    if (_isProcessing || _hasPaid) return false;
    _isProcessing = true;
    _paymentError = null;
    notifyListeners();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('Not authenticated');

      final success = await _stripeService.processPayment(
        amount: amount,
        type: 'paid_access',
        artistId: artistId,
        performanceId: performanceId,
      );

      if (success) {
        _hasPaid = true;
        notifyListeners();

        // Payment sheet completed. On native the webhook fires asynchronously,
        // so poll checkAccess in the background until Firestore is updated.
        // This ensures the user won't see the paywall if they leave and re-enter.
        if (!kIsWeb) {
          _pollAccessInBackground(userId: userId, performanceId: performanceId);
        }

        return true;
      }

      // On web ONLY: processPayment returns false (checkout launched in browser).
      // Poll checkAccess until the webhook confirms payment.
      if (kIsWeb) {
        for (var i = 0; i < 30; i++) {
          await Future.delayed(const Duration(seconds: 2));
          try {
            final result = await _stripeService.checkAccess(
              userId: userId,
              performanceId: performanceId,
            );
            if (result['hasAccess'] == true) {
              _hasPaid = true;
              notifyListeners();
              return true;
            }
          } catch (_) {
            // Keep polling
          }
        }
      }

      // Native: payment was cancelled or failed — do NOT grant access.
      return false;
    } catch (e) {
      _paymentError = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Polls the backend until Firestore reflects the payment (webhook may be
  /// a few seconds behind the PaymentSheet completion on native).
  void _pollAccessInBackground({
    required String userId,
    required String performanceId,
  }) {
    Future(() async {
      for (var i = 0; i < 20; i++) {
        await Future.delayed(const Duration(seconds: 3));
        try {
          final result = await _stripeService.checkAccess(
            userId: userId,
            performanceId: performanceId,
          );
          if (result['hasAccess'] == true) return; // Firestore is up to date
        } catch (_) {}
      }
    });
  }

  Future<void> checkAccess({
    required String userId,
    required String performanceId,
  }) async {
    if (!kIsWeb && Platform.isIOS) {
      _hasPaid = true;
      notifyListeners();
      return;
    }
    try {
      final result = await _stripeService.checkAccess(
        userId: userId,
        performanceId: performanceId,
      );
      _hasPaid = result['hasAccess'] == true;
      notifyListeners();
    } catch (e) {
      appPrint('[Tipping] Error checking access: $e');
    }
  }

  void reset() {
    _hasPaid = false;
    _paymentError = null;
    _tipHistory.clear();
    _isProcessing = false;
    notifyListeners();
  }
}
