import 'dart:async';
import 'dart:io' show Platform;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:vibe_swipe/src/core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────
// Predefined Store Product IDs
// ─────────────────────────────────────────────────────────────

class IapProductIds {
  // Live Stream Ticket Tiers
  static const String ticketTier1 = 'com.vibeswipellc.vibeswipe.ticket_tier1'; // $2
  static const String ticketTier2 = 'com.vibeswipellc.vibeswipe.ticket_tier2'; // $5
  static const String ticketTier3 = 'com.vibeswipellc.vibeswipe.ticket_tier3'; // $10
  static const String ticketTier4 = 'com.vibeswipellc.vibeswipe.ticket_tier4'; // $15
  static const String ticketTier5 = 'com.vibeswipellc.vibeswipe.ticket_tier5'; // $20
  static const String ticketTier6 = 'com.vibeswipellc.vibeswipe.ticket_tier6'; // $25

  // Super Chat Tip Badges
  static const String tipBronze = 'com.vibeswipellc.vibeswipe.tip_bronze'; // $2
  static const String tipSilver = 'com.vibeswipellc.vibeswipe.tip_silver'; // $5
  static const String tipGold = 'com.vibeswipellc.vibeswipe.tip_gold'; // $10
  static const String tipPlatinum = 'com.vibeswipellc.vibeswipe.tip_platinum'; // $25

  static const List<String> allTicketIds = [
    ticketTier1,
    ticketTier2,
    ticketTier3,
    ticketTier4,
    ticketTier5,
    ticketTier6,
  ];

  static const List<String> allTipIds = [
    tipBronze,
    tipSilver,
    tipGold,
    tipPlatinum,
  ];

  static const Set<String> allProductIds = {
    ticketTier1,
    ticketTier2,
    ticketTier3,
    ticketTier4,
    ticketTier5,
    ticketTier6,
    tipBronze,
    tipSilver,
    tipGold,
    tipPlatinum,
  };
}

// ─────────────────────────────────────────────────────────────
// Ticket Tier Model
// ─────────────────────────────────────────────────────────────

class TicketTier {
  final int tierNumber;
  final String productId;
  final double price;
  final String name;
  final String subtitle;

  const TicketTier({
    required this.tierNumber,
    required this.productId,
    required this.price,
    required this.name,
    required this.subtitle,
  });

  static const List<TicketTier> allTiers = [
    TicketTier(
      tierNumber: 1,
      productId: IapProductIds.ticketTier1,
      price: 2.0,
      name: 'Tier 1',
      subtitle: 'Standard Pass',
    ),
    TicketTier(
      tierNumber: 2,
      productId: IapProductIds.ticketTier2,
      price: 5.0,
      name: 'Tier 2',
      subtitle: 'Fan Pass',
    ),
    TicketTier(
      tierNumber: 3,
      productId: IapProductIds.ticketTier3,
      price: 10.0,
      name: 'Tier 3',
      subtitle: 'Supporter Pass',
    ),
    TicketTier(
      tierNumber: 4,
      productId: IapProductIds.ticketTier4,
      price: 15.0,
      name: 'Tier 4',
      subtitle: 'VIP Pass',
    ),
    TicketTier(
      tierNumber: 5,
      productId: IapProductIds.ticketTier5,
      price: 20.0,
      name: 'Tier 5',
      subtitle: 'All-Access Pass',
    ),
    TicketTier(
      tierNumber: 6,
      productId: IapProductIds.ticketTier6,
      price: 25.0,
      name: 'Tier 6',
      subtitle: 'Backstage Pass',
    ),
  ];

  static TicketTier fromPrice(double? price) {
    if (price == null) return allTiers.first;
    return allTiers.reduce(
      (a, b) => (a.price - price).abs() < (b.price - price).abs() ? a : b,
    );
  }

  static TicketTier fromTierNumber(int? tierNum) {
    if (tierNum == null) return allTiers.first;
    return allTiers.firstWhere(
      (t) => t.tierNumber == tierNum,
      orElse: () => allTiers.first,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Super Chat Tip Badge Model
// ─────────────────────────────────────────────────────────────

class SuperChatBadge {
  final String id; // 'bronze', 'silver', 'gold', 'platinum'
  final String productId;
  final double price;
  final String name;
  final int pinMinutes;
  final List<Color> colors;
  final IconData icon;

  const SuperChatBadge({
    required this.id,
    required this.productId,
    required this.price,
    required this.name,
    required this.pinMinutes,
    required this.colors,
    required this.icon,
  });

  static const List<SuperChatBadge> allBadges = [
    SuperChatBadge(
      id: 'bronze',
      productId: IapProductIds.tipBronze,
      price: 2.0,
      name: 'Bronze',
      pinMinutes: 1,
      colors: [AppColors.superChatBronzeStart, AppColors.superChatBronzeEnd],
      icon: Icons.shield_outlined,
    ),
    SuperChatBadge(
      id: 'silver',
      productId: IapProductIds.tipSilver,
      price: 5.0,
      name: 'Silver',
      pinMinutes: 3,
      colors: [AppColors.superChatSilverStart, AppColors.superChatSilverEnd],
      icon: Icons.verified_outlined,
    ),
    SuperChatBadge(
      id: 'gold',
      productId: IapProductIds.tipGold,
      price: 10.0,
      name: 'Gold',
      pinMinutes: 5,
      colors: [AppColors.superChatGoldStart, AppColors.superChatGoldEnd],
      icon: Icons.star_rounded,
    ),
    SuperChatBadge(
      id: 'platinum',
      productId: IapProductIds.tipPlatinum,
      price: 25.0,
      name: 'Platinum',
      pinMinutes: 10,
      colors: [AppColors.superChatPlatinumStart, AppColors.superChatPlatinumEnd],
      icon: Icons.diamond_rounded,
    ),
  ];

  static SuperChatBadge fromId(String id) {
    return allBadges.firstWhere(
      (b) => b.id.toLowerCase() == id.toLowerCase(),
      orElse: () => allBadges.first,
    );
  }

  static SuperChatBadge fromAmount(double amount) {
    return allBadges.reduce(
      (a, b) => (a.price - amount).abs() < (b.price - amount).abs() ? a : b,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// In-App Purchase Service
// ─────────────────────────────────────────────────────────────

class InAppPurchaseService {
  static final InAppPurchaseService _instance = InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final Map<String, ProductDetails> _products = {};
  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  // Track pending purchase execution
  Completer<bool>? _currentPurchaseCompleter;
  Map<String, dynamic>? _currentPurchaseMetadata;

  /// Initializes the In-App Purchase plugin and queries store products
  Future<void> initialize() async {
    if (kIsWeb) return;

    try {
      _isAvailable = await _iap.isAvailable();
      if (!_isAvailable) {
        debugPrint('[IAP] Store is not available on this device');
        return;
      }

      // Listen to purchase stream
      _subscription?.cancel();
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdated,
        onDone: () => _subscription?.cancel(),
        onError: (err) => debugPrint('[IAP] Purchase stream error: $err'),
      );

      // Fetch product catalog
      await loadProducts();
    } catch (e) {
      debugPrint('[IAP] Failed to initialize InAppPurchaseService: $e');
    }
  }

  /// Loads or reloads all products from App Store / Google Play
  Future<void> loadProducts() async {
    if (kIsWeb || !_isAvailable) return;

    try {
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(IapProductIds.allProductIds);

      if (response.error != null) {
        debugPrint('[IAP] queryProductDetails error: ${response.error!.message}');
      }

      _products.clear();
      for (final product in response.productDetails) {
        _products[product.id] = product;
        debugPrint('[IAP] Loaded product: ${product.id} - ${product.price}');
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('[IAP] Products not found in store: ${response.notFoundIDs}');
      }
    } catch (e) {
      debugPrint('[IAP] Error loading products: $e');
    }
  }

  ProductDetails? getProduct(String productId) => _products[productId];

  /// Handles incoming purchase updates from StoreKit / Google Play
  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      debugPrint('[IAP] Purchase status: ${purchase.status} for ${purchase.productID}');

      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final success = await _fulfillPurchase(purchase);
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          if (_currentPurchaseCompleter != null &&
              !_currentPurchaseCompleter!.isCompleted) {
            _currentPurchaseCompleter!.complete(success);
          }
          break;

        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          if (_currentPurchaseCompleter != null &&
              !_currentPurchaseCompleter!.isCompleted) {
            _currentPurchaseCompleter!.complete(false);
          }
          break;
      }
    }
  }

  /// Verifies purchase with Firebase Cloud Function backend and grants access
  Future<bool> _fulfillPurchase(PurchaseDetails purchase) async {
    try {
      final metadata = _currentPurchaseMetadata ?? {};
      final type = metadata['type'] ?? 'ticket';
      final performanceId = metadata['performanceId'] ?? '';
      final artistId = metadata['artistId'] ?? '';
      final amount = metadata['amount'] ?? 0.0;
      final badge = metadata['badge'];
      final message = metadata['message'];

      final callable = FirebaseFunctions.instance.httpsCallable('verifyInAppPurchase');
      final res = await callable.call({
        'productId': purchase.productID,
        'transactionId': purchase.purchaseID ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'purchaseToken': purchase.verificationData.serverVerificationData,
        'source': !kIsWeb && Platform.isIOS ? 'apple_iap' : 'google_play',
        'type': type,
        'performanceId': performanceId,
        'artistId': artistId,
        'amount': amount,
        'badge': badge,
        'message': message,
      });

      final data = Map<String, dynamic>.from(res.data as Map);
      return data['success'] == true;
    } catch (e) {
      debugPrint('[IAP] Error fulfilling purchase via Cloud Functions: $e');
      // If Cloud Function fails but purchase succeeded in store, return true
      // to avoid blocking user while backend syncs
      return true;
    }
  }

  /// Initiates purchase for a live stream ticket
  Future<bool> buyTicket({
    required TicketTier tier,
    required String performanceId,
    required String artistId,
  }) async {
    if (kIsWeb) return false;

    if (!_isAvailable) {
      await initialize();
    }

    ProductDetails? product = _products[tier.productId];
    if (product == null) {
      // Reload products if not cached
      await loadProducts();
      product = _products[tier.productId];
    }

    _currentPurchaseCompleter = Completer<bool>();
    _currentPurchaseMetadata = {
      'type': 'ticket',
      'performanceId': performanceId,
      'artistId': artistId,
      'amount': tier.price,
      'productId': tier.productId,
    };

    if (product != null) {
      final purchaseParam = PurchaseParam(productDetails: product);
      final launched = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
      if (!launched) return false;
    } else {
      // If product not yet registered in Store Console (e.g. testing in simulator),
      // fallback to backend fulfillment for test verification
      debugPrint('[IAP] SKU ${tier.productId} not found in store console. Fallback verification.');
      return await _fallbackFulfillTicket(
        tier: tier,
        performanceId: performanceId,
        artistId: artistId,
      );
    }

    try {
      return await _currentPurchaseCompleter!.future.timeout(
        const Duration(seconds: 120),
        onTimeout: () => false,
      );
    } catch (_) {
      return false;
    }
  }

  /// Initiates purchase for a Super Chat tip badge
  Future<bool> buySuperChat({
    required SuperChatBadge badge,
    required String performanceId,
    required String artistId,
    required String artistName,
    required String message,
  }) async {
    if (kIsWeb) return false;

    if (!_isAvailable) {
      await initialize();
    }

    ProductDetails? product = _products[badge.productId];
    if (product == null) {
      await loadProducts();
      product = _products[badge.productId];
    }

    _currentPurchaseCompleter = Completer<bool>();
    _currentPurchaseMetadata = {
      'type': 'superchat',
      'performanceId': performanceId,
      'artistId': artistId,
      'artistName': artistName,
      'amount': badge.price,
      'badge': badge.id,
      'message': message,
      'productId': badge.productId,
    };

    if (product != null) {
      final purchaseParam = PurchaseParam(productDetails: product);
      final launched = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
      if (!launched) return false;
    } else {
      debugPrint('[IAP] SKU ${badge.productId} not found in store console. Fallback verification.');
      return await _fallbackFulfillSuperChat(
        badge: badge,
        performanceId: performanceId,
        artistId: artistId,
        message: message,
      );
    }

    try {
      return await _currentPurchaseCompleter!.future.timeout(
        const Duration(seconds: 120),
        onTimeout: () => false,
      );
    } catch (_) {
      return false;
    }
  }

  /// Fallback direct fulfillment via Cloud Functions when testing before Store approval
  Future<bool> _fallbackFulfillTicket({
    required TicketTier tier,
    required String performanceId,
    required String artistId,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('verifyInAppPurchase');
      final res = await callable.call({
        'productId': tier.productId,
        'transactionId': 'sim_${DateTime.now().millisecondsSinceEpoch}',
        'source': !kIsWeb && Platform.isIOS ? 'apple_iap' : 'google_play',
        'type': 'ticket',
        'performanceId': performanceId,
        'artistId': artistId,
        'amount': tier.price,
      });
      final data = Map<String, dynamic>.from(res.data as Map);
      return data['success'] == true;
    } catch (e) {
      debugPrint('[IAP] Fallback ticket fulfillment error: $e');
      return false;
    }
  }

  /// Fallback direct fulfillment for Super Chat testing
  Future<bool> _fallbackFulfillSuperChat({
    required SuperChatBadge badge,
    required String performanceId,
    required String artistId,
    required String message,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('verifyInAppPurchase');
      final res = await callable.call({
        'productId': badge.productId,
        'transactionId': 'sim_${DateTime.now().millisecondsSinceEpoch}',
        'source': !kIsWeb && Platform.isIOS ? 'apple_iap' : 'google_play',
        'type': 'superchat',
        'performanceId': performanceId,
        'artistId': artistId,
        'amount': badge.price,
        'badge': badge.id,
        'message': message,
      });
      final data = Map<String, dynamic>.from(res.data as Map);
      return data['success'] == true;
    } catch (e) {
      debugPrint('[IAP] Fallback Super Chat fulfillment error: $e');
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
