import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/entities/artist_stat_entity.dart';
import '../../domain/entities/campaign_entity.dart';

final artistHomeControllerProvider =
    ChangeNotifierProvider.autoDispose<ArtistHomeController>(
      (ref) => ArtistHomeController(),
    );

class ArtistHomeController extends ChangeNotifier with Buffers {
  String _artistName = '';
  String get artistName => _artistName;

  bool _stripePayoutsEnabled = false;
  bool get stripePayoutsEnabled => _stripePayoutsEnabled;

  bool _hasCheckedPayouts = false;
  bool get hasCheckedPayouts => _hasCheckedPayouts;

  List<ArtistStatEntity> _stats = const [
    ArtistStatEntity(
      iconAsset: 'assets/icons/png/music-icon.png',
      icon: Icons.music_note_rounded,
      iconColor: AppColors.listenerActiveTab,
      value: '0',
      label: 'Total Tracks',
    ),
    ArtistStatEntity(
      iconAsset: 'assets/icons/png/artist_home_heart_icn.png',
      icon: Icons.favorite_rounded,
      iconColor: AppColors.listenerActiveTab,
      value: '0',
      label: 'Total Saves',
    ),
    ArtistStatEntity(
      icon: Icons.thumb_up_outlined,
      iconColor: AppColors.mintGreen,
      value: '0',
      label: 'Likes',
    ),
    ArtistStatEntity(
      icon: Icons.trending_up_rounded,
      iconColor: AppColors.listenerActiveTab,
      value: '0%',
      label: 'Engagement Rate',
    ),
  ];
  List<ArtistStatEntity> get stats => _stats;

  final List<CampaignEntity> _campaigns = const [
    CampaignEntity(
      title: 'Summer Acoustic Tour 2026',
      subtitle: 'Targeting indie and pop listeners across Texas & California',
      isActive: true,
    ),
    CampaignEntity(
      title: '"Echoes of You" Single Push',
      subtitle: 'Featured showcase in Indie & Acoustic radar feeds',
      isActive: true,
    ),
  ];
  List<CampaignEntity> get campaigns => _campaigns;

  final List<ActivityEntity> _recentActivity = const [
    ActivityEntity(
      iconBgColor: AppColors.listenerActiveTab,
      icon: Icons.favorite_rounded,
      description: 'Sarah J. and 48 others saved "Echoes of You"',
      timeAgo: '15m ago',
    ),
    ActivityEntity(
      iconBgColor: AppColors.mintGreen,
      icon: Icons.play_arrow_rounded,
      description: '"Midnight Waves" surpassed 1,800 live streams',
      timeAgo: '1h ago',
    ),
    ActivityEntity(
      iconBgColor: Color(0xFF6C5CE7),
      icon: Icons.chat_bubble_rounded,
      description: 'Marcus D. commented on your community discussion',
      timeAgo: '2h ago',
    ),
    ActivityEntity(
      iconBgColor: Color(0xFF0984E3),
      icon: Icons.person_add_rounded,
      description: '24 new listeners followed your artist profile',
      timeAgo: '4h ago',
    ),
  ];
  List<ActivityEntity> get recentActivity => _recentActivity;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ArtistHomeController() {
    fetchArtistName();
    fetchStats();
  }

  Future<void> fetchArtistName() async {
    try {
      final uid = locator<FirebaseAuthService>().getUid();
      if (uid == null) return;
      final data = await locator<FirestoreService>().getUserData(uid);
      if (data != null) {
        _artistName = (data['artistName'] ?? data['name'] ?? '').toString();
        _stripePayoutsEnabled = data['stripeOnboardingComplete'] == true;
        _hasCheckedPayouts = true;
        notifyListeners();
      }
    } catch (e) {
      appPrint('[ArtistHome] Error fetching artist name: $e');
    }
  }

  Future<void> fetchStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await locator<FirestoreService>().getArtistStats();
      if (data != null) {
        final totalTracks = data['totalTracks'] ?? 0;
        final totalSaves = data['totalSaves'] ?? 0;
        final totalLikes = data['totalLikes'] ?? 0;
        final engagementRate = data['engagementRate'] ?? 0.0;

        _stats = [
          ArtistStatEntity(
            iconAsset: 'assets/icons/png/music-icon.png',
            icon: Icons.music_note_rounded,
            iconColor: AppColors.listenerActiveTab,
            value: '$totalTracks',
            label: 'Total Tracks',
          ),
          ArtistStatEntity(
            iconAsset: 'assets/icons/png/artist_home_heart_icn.png',
            icon: Icons.favorite_rounded,
            iconColor: AppColors.listenerActiveTab,
            value: '$totalSaves',
            label: 'Total Saves',
          ),
          ArtistStatEntity(
            icon: Icons.thumb_up_outlined,
            iconColor: AppColors.mintGreen,
            value: '$totalLikes',
            label: 'Likes',
          ),
          ArtistStatEntity(
            icon: Icons.trending_up_rounded,
            iconColor: AppColors.listenerActiveTab,
            value: '${engagementRate.toStringAsFixed(1)}%',
            label: 'Engagement Rate',
          ),
        ];
      } else {
        _stats = _defaultStats();
      }
    } catch (e) {
      appPrint('[ArtistHome] Error fetching stats: $e');
      _stats = _defaultStats();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<ArtistStatEntity> _defaultStats() => const [
    ArtistStatEntity(
      iconAsset: 'assets/icons/png/music-icon.png',
      icon: Icons.music_note_rounded,
      iconColor: AppColors.listenerActiveTab,
      value: '0',
      label: 'Total Tracks',
    ),
    ArtistStatEntity(
      iconAsset: 'assets/icons/png/artist_home_heart_icn.png',
      icon: Icons.favorite_rounded,
      iconColor: AppColors.listenerActiveTab,
      value: '0',
      label: 'Total Saves',
    ),
    ArtistStatEntity(
      icon: Icons.thumb_up_outlined,
      iconColor: AppColors.mintGreen,
      value: '0',
      label: 'Likes',
    ),
    ArtistStatEntity(
      icon: Icons.trending_up_rounded,
      iconColor: AppColors.listenerActiveTab,
      value: '0%',
      label: 'Engagement Rate',
    ),
  ];
}
