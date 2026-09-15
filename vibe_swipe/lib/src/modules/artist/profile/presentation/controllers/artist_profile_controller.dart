import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/core/constants/app_constants.dart';
import 'package:vibe_swipe/src/modules/artist/profile/domain/entities/topic_entity.dart';

final artistProfileControllerProvider =
    ChangeNotifierProvider.autoDispose<ArtistProfileController>(
      (ref) => ArtistProfileController()..fetchUserData(),
    );

class ArtistProfileController extends ChangeNotifier with Buffers {
  String _artistName = '';
  String _artistEmail = '';
  String? _artistImageUrl;
  String? _bannerUrl;
  String _bio = '';
  List<String> _socialLinks = [];
  int _tracksCount = 0;
  int _responsesCount = 0;
  int _savesCount = 0;

  ArtistProfileController() {
    _fetchTopics();
  }

  String get artistName => _artistName;
  String get artistEmail => _artistEmail;
  String? get artistImageUrl => _artistImageUrl;
  String? get bannerUrl => _bannerUrl;
  String get bio => _bio;
  List<String> get socialLinks => List.unmodifiable(_socialLinks);
  int get tracksCount => _tracksCount;
  int get responsesCount => _responsesCount;
  int get savesCount => _savesCount;

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
        _artistName = data['artistName'] ?? data['name'] ?? '';
        _artistEmail = data['email'] ?? '';
        _artistImageUrl = data['profileImageUrl'];
        _bannerUrl = data['coverUrl'];
        _bio = data['bio'] ?? '';
        _socialLinks = List<String>.from(data['socialLinksList'] ?? []);
        _selectedGenres.clear();
        _selectedGenres.addAll(Set<String>.from(data['genres'] ?? []));
        publicProfile = data['isPublicProfile'] ?? true;

        final socialLinksMap = data['socialLinks'];
        if (socialLinksMap is Map) {
          _spotifyUrl = socialLinksMap['spotify'] ?? '';
          _youtubeUrl = socialLinksMap['youtube'] ?? '';
          _instagramUrl = socialLinksMap['instagram'] ?? '';
        }

        // Load notification preferences
        final notifPrefs = data['notificationPrefs'];
        if (notifPrefs is Map) {
          trackPerformance = notifPrefs['trackPerformance'] ?? false;
          campaignUpdates = notifPrefs['campaignUpdates'] ?? false;
          trackComments = notifPrefs['trackComments'] ?? false;
          newFollowers = notifPrefs['newFollowers'] ?? false;
          platformMessages = notifPrefs['platformMessages'] ?? false;
          marketingUpdates = notifPrefs['marketingUpdates'] ?? false;
        }

        // Load privacy preferences
        final privacyPrefs = data['privacyPrefs'];
        if (privacyPrefs is Map) {
          showEmailAddress = privacyPrefs['showEmailAddress'] ?? false;
          showSocialLinks = privacyPrefs['showSocialLinks'] ?? true;
          allowDirectMessages = privacyPrefs['allowDirectMessages'] ?? true;
        }
      }

      final stats = await locator<FirestoreService>().getArtistStats();
      if (stats != null) {
        _tracksCount = stats['totalTracks'] ?? 0;
        _savesCount = stats['totalSaves'] ?? 0;
        _responsesCount = stats['totalComments'] ?? 0;
      }
    } catch (e) {
      appPrint('[ArtistProfile] Error fetching user data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchTopics() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('help_topics')
          .orderBy('order')
          .get();
      _topics = snapshot.docs.map((doc) {
        final data = doc.data();
        return TopicEntity(
          title: data['title'] ?? '',
          subtitle: data['subtitle'] ?? '',
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      appPrint('[ArtistProfile] Error fetching topics: $e');
      _topics = [];
    }
  }

  // ── Edit Profile ──────────────────────────────────────────────
  XFile? pickedImage;
  Uint8List? pickedImageBytes;
  XFile? pickedBannerImage;
  Uint8List? pickedBannerImageBytes;

  String _spotifyUrl = '';
  String _youtubeUrl = '';
  String _instagramUrl = '';

  String get spotifyUrl => _spotifyUrl;
  String get youtubeUrl => _youtubeUrl;
  String get instagramUrl => _instagramUrl;

  void setSpotifyUrl(String value) { _spotifyUrl = value; notifyListeners(); }
  void setYoutubeUrl(String value) { _youtubeUrl = value; notifyListeners(); }
  void setInstagramUrl(String value) { _instagramUrl = value; notifyListeners(); }

  Future<void> setPickedImage(XFile? file) async {
    pickedImage = file;
    pickedImageBytes = file != null ? await file.readAsBytes() : null;
    notifyListeners();
  }

  Future<void> setPickedBannerImage(XFile? file) async {
    pickedBannerImage = file;
    pickedBannerImageBytes = file != null ? await file.readAsBytes() : null;
    notifyListeners();
  }

  void showImageSourceSheet(BuildContext context) {
    ImageSourceSheet.show(context, setPickedImage);
  }

  void showBannerSourceSheet(BuildContext context) {
    ImageSourceSheet.show(context, setPickedBannerImage);
  }

  static const List<String> genreOptions = AppConstants.genres;

  final Set<String> _selectedGenres = {};
  Set<String> get selectedGenres => Set.unmodifiable(_selectedGenres);

  void toggleGenre(String genre) {
    _selectedGenres.contains(genre)
        ? _selectedGenres.remove(genre)
        : _selectedGenres.add(genre);
    notifyListeners();
  }

  bool publicProfile = true;

  void togglePublicProfile(bool value) {
    publicProfile = value;
    notifyListeners();
  }

  Future<void> onSaveChanges({
    required String artistName,
    required String bio,
    String? spotifyUrl,
    String? youtubeUrl,
    String? instagramUrl,
  }) async {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null) return;

    String? profileImageUrl = _artistImageUrl;
    if (pickedImageBytes != null) {
      profileImageUrl = await locator<FirestoreService>().uploadProfileImage(uid, pickedImageBytes!);
    }

    String? coverUrl = _bannerUrl;
    if (pickedBannerImageBytes != null) {
      coverUrl = await locator<FirestoreService>().uploadBannerImage(uid, pickedBannerImageBytes!);
    }

    await locator<FirestoreService>().updateUserData(uid, {
      'artistName': artistName,
      'bio': bio,
      'genres': _selectedGenres.toList(),
      'socialLinks': {
        'spotify': spotifyUrl ?? '',
        'youtube': youtubeUrl ?? '',
        'instagram': instagramUrl ?? '',
      },
      'isPublicProfile': publicProfile,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (coverUrl != null) 'coverUrl': coverUrl,
    });

    _artistName = artistName;
    _bio = bio;
    _artistImageUrl = profileImageUrl;
    _bannerUrl = coverUrl;
    _spotifyUrl = spotifyUrl ?? '';
    _youtubeUrl = youtubeUrl ?? '';
    _instagramUrl = instagramUrl ?? '';
    pickedImage = null;
    pickedBannerImage = null;
    pickedBannerImageBytes = null;
    notifyListeners();
    AppRouterGo.back();
  }

  // ── Notification Settings ─────────────────────────────────────
  bool trackPerformance = false;
  bool campaignUpdates = false;
  bool trackComments = false;
  bool newFollowers = false;
  bool platformMessages = false;
  bool marketingUpdates = false;

  void toggleTrackPerformance(bool v) {
    trackPerformance = v;
    _saveNotificationPrefs();
    notifyListeners();
  }

  void toggleCampaignUpdates(bool v) {
    campaignUpdates = v;
    _saveNotificationPrefs();
    notifyListeners();
  }

  void toggleTrackComments(bool v) {
    trackComments = v;
    _saveNotificationPrefs();
    notifyListeners();
  }

  void toggleNewFollowers(bool v) {
    newFollowers = v;
    _saveNotificationPrefs();
    notifyListeners();
  }

  void togglePlatformMessages(bool v) {
    platformMessages = v;
    _saveNotificationPrefs();
    notifyListeners();
  }

  void toggleMarketingUpdates(bool v) {
    marketingUpdates = v;
    _saveNotificationPrefs();
    notifyListeners();
  }

  void _saveNotificationPrefs() {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null) return;
    locator<FirestoreService>().updateUserData(uid, {
      'notificationPrefs': {
        'trackPerformance': trackPerformance,
        'campaignUpdates': campaignUpdates,
        'trackComments': trackComments,
        'newFollowers': newFollowers,
        'platformMessages': platformMessages,
        'marketingUpdates': marketingUpdates,
      },
    });
  }

  // ── Privacy Settings ──────────────────────────────────────────
  bool showEmailAddress = false;
  bool showSocialLinks = true;
  bool allowDirectMessages = true;

  void toggleShowEmailAddress(bool v) {
    showEmailAddress = v;
    _savePrivacyPrefs();
    notifyListeners();
  }

  void toggleShowSocialLinks(bool v) {
    showSocialLinks = v;
    _savePrivacyPrefs();
    notifyListeners();
  }

  void toggleAllowDirectMessages(bool v) {
    allowDirectMessages = v;
    _savePrivacyPrefs();
    notifyListeners();
  }

  void _savePrivacyPrefs() {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null) return;
    locator<FirestoreService>().updateUserData(uid, {
      'privacyPrefs': {
        'showEmailAddress': showEmailAddress,
        'showSocialLinks': showSocialLinks,
        'allowDirectMessages': allowDirectMessages,
      },
    });
  }

  void onSavePrivacySettings() => AppRouterGo.back();

  void onLogout() async {
    await AuthHandler.ref.logout();
    AppRouterGo.pushRemoveUntil(loginView);
  }

  // ── Help & Support ────────────────────────────────────────────
  List<TopicEntity> _topics = [];
  List<TopicEntity> get topics => _topics;
}
