import 'package:url_launcher/url_launcher.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/earning_entities.dart';

final artistEarningsControllerProvider =
    ChangeNotifierProvider.autoDispose<ArtistEarningsController>(
      (ref) => ArtistEarningsController(),
    );

class ArtistEarningsController extends ChangeNotifier with Buffers {
  final _stripeService = StripeService();

  double _grossEarnings = 0.0;
  double get grossEarnings => _grossEarnings;

  double _storeFee = 0.0;
  double get storeFee => _storeFee;

  double _platformFee = 0.0;
  double get platformFee => _platformFee;

  double _netEarnings = 0.0;
  double get netEarnings => _netEarnings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PerformanceEarning> _performanceEarnings = [];
  List<PerformanceEarning> get performanceEarnings => _performanceEarnings;

  final List<PayoutRecord> _pendingPayouts = [];
  List<PayoutRecord> get pendingPayouts => _pendingPayouts;

  final List<PayoutRecord> _paidPayouts = [];
  List<PayoutRecord> get paidPayouts => _paidPayouts;

  List<Map<String, dynamic>> _recentTips = [];
  List<Map<String, dynamic>> get recentTips => _recentTips;

  Map<String, dynamic> _payoutWallet = {};
  Map<String, dynamic> get payoutWallet => _payoutWallet;

  String? _stripeAccountId;
  String? get stripeAccountId => _stripeAccountId;

  bool _stripePayoutsEnabled = false;
  bool get stripePayoutsEnabled => _stripePayoutsEnabled;

  double _pendingPayoutBalance = 0.0;
  double get pendingPayoutBalance => _pendingPayoutBalance;

  bool get isWalletConfigured => _stripePayoutsEnabled;

  ArtistEarningsController() {
    fetchEarnings();
  }

  Future<void> fetchEarnings() async {
    final userId = locator<FirebaseAuthService>().getUid();
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final userData = await locator<FirestoreService>().getUserData(userId);
      if (userData != null) {
        _payoutWallet = Map<String, dynamic>.from(userData['payoutWallet'] ?? {});
        _stripeAccountId = userData['stripeAccountId'] as String?;
        _stripePayoutsEnabled = userData['stripeOnboardingComplete'] == true;
        _pendingPayoutBalance = ((userData['pendingPayout'] ?? 0) as num).toDouble() / 100;
      }

      final data = await _stripeService.getTransactionHistory(userId);

      _grossEarnings = (data['grossEarnings'] ?? 0).toDouble() / 100;
      _storeFee = (data['storeFee'] ?? 0).toDouble() / 100;
      _platformFee = (data['platformFee'] ?? 0).toDouble() / 100;
      _netEarnings = (data['netEarnings'] ?? 0).toDouble() / 100;

      final transactions = data['transactions'] as List? ?? [];

      final Map<String, PerformanceEarning> earningsByPerf = {};
      
      for (final tx in transactions) {
        final type = tx['type'] ?? '';
        final amount = ((tx['amount'] ?? 0) as num).toDouble() / 100;
        final fee = ((tx['platformFee'] ?? 0) as num).toDouble() / 100;
        final net = ((tx['netAmount'] ?? 0) as num).toDouble() / 100;
        final perfId = tx['performanceId'] ?? 'general';
        final createdAt = tx['createdAt'];
        DateTime date = DateTime.now();
        if (createdAt != null && createdAt is Map && createdAt['_seconds'] != null) {
          date = DateTime.fromMillisecondsSinceEpoch((createdAt['_seconds'] * 1000).toInt());
        } else if (createdAt is num) {
          date = DateTime.fromMillisecondsSinceEpoch((createdAt * 1000).toInt());
        }

        if (type == 'tip') {
          if (!earningsByPerf.containsKey(perfId)) {
            earningsByPerf[perfId] = PerformanceEarning(
              performanceTitle: 'Tips & Donations',
              date: date,
              grossAmount: 0,
              platformFee: 0,
              netAmount: 0,
              viewerCount: 0,
              tipCount: 0,
            );
          }
          final existing = earningsByPerf[perfId]!;
          earningsByPerf[perfId] = PerformanceEarning(
            performanceTitle: existing.performanceTitle,
            date: date.isAfter(existing.date) ? date : existing.date,
            grossAmount: existing.grossAmount + amount,
            platformFee: existing.platformFee + fee,
            netAmount: existing.netAmount + net,
            viewerCount: existing.viewerCount,
            tipCount: existing.tipCount + 1,
          );
        } else if (type == 'paid_access') {
          final source = perfId.isNotEmpty ? perfId : 'Performance';
          if (!earningsByPerf.containsKey(perfId)) {
            earningsByPerf[perfId] = PerformanceEarning(
              performanceTitle: source,
              date: date,
              grossAmount: 0,
              platformFee: 0,
              netAmount: 0,
              viewerCount: 0,
              tipCount: 0,
            );
          }
          final existing = earningsByPerf[perfId]!;
          earningsByPerf[perfId] = PerformanceEarning(
            performanceTitle: existing.performanceTitle,
            date: date.isAfter(existing.date) ? date : existing.date,
            grossAmount: existing.grossAmount + amount,
            platformFee: existing.platformFee + fee,
            netAmount: existing.netAmount + net,
            viewerCount: existing.viewerCount + 1,
            tipCount: existing.tipCount,
          );
        }
      }

      _performanceEarnings = earningsByPerf.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      _recentTips = transactions
          .where((tx) => tx['type'] == 'tip')
          .take(4)
          .map((tx) => {
                'from': tx['userId'] ?? 'Anonymous',
                'amount': ((tx['amount'] ?? 0) as num).toDouble() / 100,
                'time': _formatTime(tx['createdAt']),
              })
          .toList();
    } catch (e) {
      appPrint('[Earnings] Error fetching earnings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatTime(dynamic createdAt) {
    if (createdAt != null && createdAt is Map && createdAt['_seconds'] != null) {
      final date = DateTime.fromMillisecondsSinceEpoch((createdAt['_seconds'] * 1000).toInt());
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } else if (createdAt is num) {
      final date = DateTime.fromMillisecondsSinceEpoch((createdAt * 1000).toInt());
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    }
    return 'recently';
  }

  double get pendingTotal => _pendingPayoutBalance;
  double get paidTotal => _paidPayouts.fold(0.0, (s, p) => s + p.amount);

  Future<void> saveWalletDetails(Map<String, dynamic> walletData) async {
    final userId = locator<FirebaseAuthService>().getUid();
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await locator<FirestoreService>().updateUserData(userId, {
        'payoutWallet': walletData,
      });
      _payoutWallet = walletData;
      notifyListeners();
    } catch (e) {
      appPrint('[Earnings] Error saving wallet: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────
  // Stripe Connect Actions
  // ─────────────────────────────────────────────────────────

  Future<void> setupStripeConnect() async {
    final userId = locator<FirebaseAuthService>().getUid();
    if (userId == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final result = await _stripeService.createConnectAccount(userId);
      final url = result['onboardingUrl'] as String?;
      final accId = result['accountId'] as String?;
      
      if (accId != null) {
        _stripeAccountId = accId;
      }
      
      if (url != null) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      appPrint('[Earnings] Error setting up Stripe Connect: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkStripeStatus() async {
    final userId = locator<FirebaseAuthService>().getUid();
    if (userId == null) return;
    
    try {
      final result = await _stripeService.getConnectAccountStatus(userId);
      if (result['connected'] == true) {
        _stripeAccountId = result['accountId'];
        _stripePayoutsEnabled = result['payoutsEnabled'] == true;
        notifyListeners();
      }
    } catch (e) {
      appPrint('[Earnings] Error checking Stripe status: $e');
    }
  }

  Future<bool> requestWithdrawal(double amount) async {
    final userId = locator<FirebaseAuthService>().getUid();
    if (userId == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await _stripeService.requestPayout(artistId: userId, amount: amount);
      await fetchEarnings(); // Refresh balance
      return true;
    } catch (e) {
      appPrint('[Earnings] Error requesting withdrawal: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
