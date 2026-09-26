import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibe_swipe/src/core/services/in_app_purchase_service.dart';
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
    String? performanceId,
    String? message,
    SuperChatBadge? badge,
  }) async {
    if (_isProcessing) return false;
    _isProcessing = true;
    _paymentError = null;
    notifyListeners();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return false;

      // ── Mobile Flow: Native Apple StoreKit / Google Play IAP ──
      if (!kIsWeb) {
        final selectedBadge = badge ?? SuperChatBadge.fromAmount(amount);
        final success = await locator<InAppPurchaseService>().buySuperChat(
          badge: selectedBadge,
          performanceId: performanceId ?? '',
          artistId: artistId,
          artistName: artistName,
          message: message ?? '',
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
        return false;
      }

      // ── Web Flow: Stripe Checkout ──
      final success = await _stripeService.processPayment(
        amount: amount,
        type: 'tip',
        artistId: artistId,
        performanceId: performanceId,
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

      // Web: Polling for webhook confirmation
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
    int? tierNumber,
  }) async {
    if (_isProcessing || _hasPaid) return false;
    _isProcessing = true;
    _paymentError = null;
    notifyListeners();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('Not authenticated');

      // ── Mobile Flow: Native Apple StoreKit / Google Play IAP ──
      if (!kIsWeb) {
        final tier = tierNumber != null
            ? TicketTier.fromTierNumber(tierNumber)
            : TicketTier.fromPrice(amount);

        final success = await locator<InAppPurchaseService>().buyTicket(
          tier: tier,
          performanceId: performanceId,
          artistId: artistId,
        );

        if (success) {
          _hasPaid = true;
          notifyListeners();
          return true;
        }
        return false;
      }

      // ── Web Flow: Stripe Checkout ──
      final success = await _stripeService.processPayment(
        amount: amount,
        type: 'paid_access',
        artistId: artistId,
        performanceId: performanceId,
      );

      if (success) {
        _hasPaid = true;
        notifyListeners();
        return true;
      }

      // Web: Polling checkAccess until webhook confirms
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
        } catch (_) {}
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

  Future<void> checkAccess({
    required String userId,
    required String performanceId,
  }) async {
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
