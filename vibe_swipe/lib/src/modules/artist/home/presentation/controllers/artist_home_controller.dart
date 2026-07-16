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

  List<CampaignEntity> _campaigns = [];
  List<CampaignEntity> get campaigns => _campaigns;

  List<ActivityEntity> _recentActivity = [];
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
