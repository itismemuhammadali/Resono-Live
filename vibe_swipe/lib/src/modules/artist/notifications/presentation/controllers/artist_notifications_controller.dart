import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/artist_notification_entity.dart';

final artistNotificationsControllerProvider =
    ChangeNotifierProvider.autoDispose<ArtistNotificationsController>(
      (ref) => ArtistNotificationsController(),
    );

class ArtistNotificationsController extends ChangeNotifier {
  List<ArtistNotificationEntity> _notifications = [];
  List<ArtistNotificationEntity> get notifications => _notifications;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  StreamSubscription<QuerySnapshot>? _subscription;

  ArtistNotificationsController() {
    _listenToNotifications();
  }

  void _listenToNotifications() {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _subscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _notifications = snapshot.docs.map((doc) {
          final data = doc.data();
          return ArtistNotificationEntity(
            iconAsset: data['iconAsset'] ?? 'assets/icons/png/artist_notification_complete_icn.png',
            iconColor: AppColors.iconGreen,
            title: data['title'] ?? '',
            timeAgo: _formatTimeAgo(data['createdAt']),
            isRead: data['isRead'] ?? false,
          );
        }).toList();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        appPrint('[ArtistNotifications] Error: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  String _formatTimeAgo(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = timestamp is Timestamp ? timestamp.toDate() : DateTime.now();
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
