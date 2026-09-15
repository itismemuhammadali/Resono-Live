import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/core/constants/app_constants.dart';
import '../../data/dtos/notification_dto.dart';
import '../../data/dtos/library_song_dto.dart';
import '../../domain/entities/faq_item.dart';

final listenerProfileControllerProvider =
    ChangeNotifierProvider.autoDispose<ListenerProfileController>(
      (ref) => ListenerProfileController()..fetchUserData(),
    );

class ListenerProfileController extends ChangeNotifier with Buffers {
  // ── User data from Firestore ──────────────────────────────────
  String _name = '';
  String _email = '';
  String _username = '';
  String _profileImageUrl = '';
  String get name => _name;
  String get email => _email;
  String get username => _username;
  String get profileImageUrl => _profileImageUrl;
  List<String> get favoriteGenres => List.unmodifiable(_selectedFavoriteGenres);
  int get genreCount => _selectedFavoriteGenres.length;

  int _likedCount = 0;
  int _savedCount = 0;
  int get likedCount => _likedCount;
  int get savedCount => _savedCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchUserData() async {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final data = await locator<FirestoreService>().getUserData(uid);
      if (data != null) {
        _name = data['name'] ?? '';
        _email = data['email'] ?? '';
        _username = data['username'] ?? '';
        _profileImageUrl = data['profileImageUrl'] ?? '';
        _selectedFavoriteGenres.clear();
        _selectedFavoriteGenres.addAll(Set<String>.from(data['favoriteGenres'] ?? []));
        _dislikedGenres.clear();
        _dislikedGenres.addAll(Set<String>.from(data['dislikedGenres'] ?? []));

        // Load notification preferences
        final notifPrefs = data['notificationPrefs'];
        if (notifPrefs is Map) {
          newSongs = notifPrefs['newSongs'] ?? false;
          promotions = notifPrefs['promotions'] ?? false;
          appUpdates = notifPrefs['appUpdates'] ?? false;
        }

        // Load privacy preferences
        final privacyPrefs = data['privacyPrefs'];
        if (privacyPrefs is Map) {
          publicProfile = privacyPrefs['publicProfile'] ?? true;
          listeningHistory = privacyPrefs['listeningHistory'] ?? false;
          savedSongs = privacyPrefs['savedSongs'] ?? true;
          dataCollection = privacyPrefs['dataCollection'] ?? true;
          shareWithArtists = privacyPrefs['shareWithArtists'] ?? false;
        }
      }

      final user = FirebaseAuth.instance.currentUser;
      if (_name.isEmpty && user?.displayName != null && user!.displayName!.isNotEmpty) {
        _name = user.displayName!;
      }
      if (_email.isEmpty && user?.email != null && user!.email!.isNotEmpty) {
        _email = user.email!;
      }
      if (_username.isEmpty) {
        _username = _name.isNotEmpty ? _name : 'Music Lover';
      }
      if (_profileImageUrl.isEmpty && user?.photoURL != null && user!.photoURL!.isNotEmpty) {
        _profileImageUrl = user.photoURL!;
      }
    } catch (e) {
      appPrint('[Profile] Error fetching user data: $e');
    }

    _isLoading = false;
    notifyListeners();

    _fetchLibraryStats();
    fetchLibraryData();
    _listenToNotifications();
    _fetchFaqs();
  }

  Future<void> _fetchLibraryStats() async {
    try {
      final data = await locator<FirestoreService>().getLibraryStats();
      if (data != null) {
        _likedCount = (data['likedCount'] is num) ? (data['likedCount'] as num).toInt() : 0;
        _savedCount = (data['savedCount'] is num) ? (data['savedCount'] as num).toInt() : 0;
        notifyListeners();
      }
    } catch (e) {
      appPrint('[Profile] Error fetching library stats: $e');
    }
  }

  void refreshSavedCount() {
    final fs = locator<FirestoreService>();
    _savedCount = fs.cachedSavedCount;
    _likedCount = fs.cachedLikedCount;
    notifyListeners();
  }
  // ── Image picker ──────────────────────────────────────────────
  XFile? pickedImage;
  Uint8List? pickedImageBytes;

  Future<void> setPickedImage(XFile? file) async {
    pickedImage = file;
    pickedImageBytes = file != null ? await file.readAsBytes() : null;
    notifyListeners();
  }

  void showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ImageSourceSheet(onPicked: setPickedImage),
    );
  }

  // ── Genres ────────────────────────────────────────────────────
  final List<String> genres = AppConstants.genres;

  final Set<String> _selectedFavoriteGenres = {};
  final Set<String> _dislikedGenres = {};

  Set<String> get selectedFavoriteGenres => Set.unmodifiable(_selectedFavoriteGenres);
  Set<String> get dislikedGenres => Set.unmodifiable(_dislikedGenres);

  void toggleFavorite(String genre) {
    _selectedFavoriteGenres.contains(genre)
        ? _selectedFavoriteGenres.remove(genre)
        : _selectedFavoriteGenres.add(genre);
    _dislikedGenres.remove(genre);
    notifyListeners();
  }

  void toggleDisliked(String genre) {
    _dislikedGenres.contains(genre)
        ? _dislikedGenres.remove(genre)
        : _dislikedGenres.add(genre);
    _selectedFavoriteGenres.remove(genre);
    notifyListeners();
  }

  // ── Notification feed ─────────────────────────────────────────
  List<NotificationDto> _notifications = [];
  List<NotificationDto> get notifications => _notifications;

  StreamSubscription<QuerySnapshot>? _notificationsSubscription;

  void _listenToNotifications() {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null) return;

    _notificationsSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _notifications = snapshot.docs.map((doc) {
          final data = doc.data();
          final typeStr = data['type'] ?? 'newSong';
          NotificationType type;
          switch (typeStr) {
            case 'promotion':
              type = NotificationType.promotion;
              break;
            case 'feature':
              type = NotificationType.feature;
              break;
            case 'trending':
              type = NotificationType.trending;
              break;
            case 'live_stream_started':
              type = NotificationType.liveStream;
              break;
            case 'scheduled_session_reminder':
              type = NotificationType.sessionReminder;
              break;
            case 'new_follower':
              type = NotificationType.newFollower;
              break;
            case 'new_performance_upload':
              type = NotificationType.newPerformance;
              break;
            case 'post_comment':
              type = NotificationType.postComment;
              break;
            case 'post_like':
              type = NotificationType.postLike;
              break;
            case 'performance_like':
              type = NotificationType.performanceLike;
              break;
            case 'tip_received':
              type = NotificationType.tipReceived;
              break;
            case 'payment_confirmed':
              type = NotificationType.paymentConfirmed;
              break;
            case 'payment_failed':
              type = NotificationType.paymentFailed;
              break;
            case 'payout_processed':
              type = NotificationType.payoutProcessed;
              break;
            default:
              type = NotificationType.newSong;
          }
          return NotificationDto(
            id: doc.id,
            title: data['title'] ?? '',
            body: data['body'] ?? '',
            fullBody: data['fullBody'] ?? data['body'] ?? '',
            time: _formatTimeAgo(data['createdAt']),
            type: type,
            isRead: data['isRead'] ?? false,
            actionLabel: data['actionLabel'],
          );
        }).toList();
        notifyListeners();
      },
      onError: (e) {
        appPrint('[Profile] Error listening to notifications: $e');
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

  // ── Notification toggles ──────────────────────────────────────
  bool newSongs = false;
  bool promotions = false;
  bool appUpdates = false;

  void toggleNewSongs(bool value) {
    newSongs = value;
    _saveNotificationPrefs();
    notifyListeners();
  }

  void togglePromotions(bool value) {
    promotions = value;
    _saveNotificationPrefs();
    notifyListeners();
  }

  void toggleAppUpdates(bool value) {
    appUpdates = value;
    _saveNotificationPrefs();
    notifyListeners();
  }

  void _saveNotificationPrefs() {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null) return;
    locator<FirestoreService>().updateUserData(uid, {
      'notificationPrefs': {
        'newSongs': newSongs,
        'promotions': promotions,
        'appUpdates': appUpdates,
      },
    });
  }

  // ── Help & Support ────────────────────────────────────────────
  List<FaqItem> _faqs = [];
  List<FaqItem> get faqs => _faqs;

  Future<void> _fetchFaqs() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('faqs')
          .orderBy('order')
          .get();
      _faqs = snapshot.docs.map((doc) {
        final data = doc.data();
        return FaqItem(
          question: data['question'] ?? '',
          answer: data['answer'] ?? '',
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      appPrint('[Profile] Error fetching FAQs: $e');
      _faqs = [];
    }
  }

  // ── Library ───────────────────────────────────────────────────
  final List<LibrarySongDto> savedSongsList = [];
  final List<LibrarySongDto> listeningHistoryList = [];

  bool _isLibraryLoading = false;
  bool get isLibraryLoading => _isLibraryLoading;

  Future<void> fetchLibraryData() async {
    _isLibraryLoading = true;
    notifyListeners();

    try {
      final savedData = await locator<FirestoreService>().getSavedSongs();
      savedSongsList.clear();
      for (final s in savedData) {
        savedSongsList.add(_parseSong(s));
      }

      final historyData = await locator<FirestoreService>().getListeningHistory();
      listeningHistoryList.clear();
      for (final h in historyData) {
        listeningHistoryList.add(_parseSong(h));
      }
    } catch (e) {
      appPrint('[Profile] Error fetching library data: $e');
    }

    _isLibraryLoading = false;
    notifyListeners();
  }

  LibrarySongDto _parseSong(Map<String, dynamic> data) {
    final genres = data['genres'] is List ? (data['genres'] as List).cast<String>() : <String>[];
    return LibrarySongDto(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      artist: data['artist'] ?? data['artistName'] ?? '',
      genre: genres.isNotEmpty ? genres.first : 'Music',
      coverUrl: data['thumbnailUrl'] ?? data['coverUrl'],
      album: data['album'],
      duration: data['duration'],
      releaseYear: data['releaseYear'],
      coverColors: const [Color(0xFF6A3093), Color(0xFFA044FF)],
    );
  }

  // ── Privacy toggles ───────────────────────────────────────────
  bool publicProfile = true;
  bool listeningHistory = false;
  bool savedSongs = true;
  bool dataCollection = true;
  bool shareWithArtists = false;

  void togglePublicProfile(bool v) { publicProfile = v; _savePrivacyPrefs(); notifyListeners(); }
  void toggleListeningHistory(bool v) { listeningHistory = v; _savePrivacyPrefs(); notifyListeners(); }
  void toggleSavedSongs(bool v) { savedSongs = v; _savePrivacyPrefs(); notifyListeners(); }
  void toggleDataCollection(bool v) { dataCollection = v; _savePrivacyPrefs(); notifyListeners(); }
  void toggleShareWithArtists(bool v) { shareWithArtists = v; _savePrivacyPrefs(); notifyListeners(); }

  void _savePrivacyPrefs() {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null) return;
    locator<FirestoreService>().updateUserData(uid, {
      'privacyPrefs': {
        'publicProfile': publicProfile,
        'listeningHistory': listeningHistory,
        'savedSongs': savedSongs,
        'dataCollection': dataCollection,
        'shareWithArtists': shareWithArtists,
      },
    });
  }

  void onSavePrivacySettings() => AppRouterGo.back();

  void onLogout() async {
    await AuthHandler.ref.logout();
    AppRouterGo.pushRemoveUntil(loginView);
  }

  Future<void> onSaveChanges({
    required String name,
    required String username,
    required String email,
  }) async {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null) return;

    String? profileImageUrl = _profileImageUrl;
    if (pickedImageBytes != null) {
      profileImageUrl = await locator<FirestoreService>().uploadProfileImage(uid, pickedImageBytes!);
    }

    await locator<FirestoreService>().updateUserData(uid, {
      'name': name,
      'username': username,
      'email': email,
      if (profileImageUrl != null && profileImageUrl != _profileImageUrl)
        'profileImageUrl': profileImageUrl,
    });

    _name = name;
    _username = username;
    _email = email;
    if (profileImageUrl != null) _profileImageUrl = profileImageUrl;
    pickedImage = null;
    pickedImageBytes = null;
    notifyListeners();
    AppRouterGo.back();
  }

  void onCancel() => AppRouterGo.back();

  Future<void> onSaveSettings() async {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid != null) {
      await locator<FirestoreService>().updateUserData(uid, {
        'favoriteGenres': _selectedFavoriteGenres.toList(),
        'dislikedGenres': _dislikedGenres.toList(),
      });
    }
    AppRouterGo.back();
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }
}
