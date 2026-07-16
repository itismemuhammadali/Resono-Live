import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/analytics_chart_data_entity.dart';
import '../../domain/entities/analytics_genre_entity.dart';
import '../../domain/entities/analytics_stat_entity.dart';
import '../../domain/entities/analytics_top_track_entity.dart';

final artistAnalyticsControllerProvider =
    ChangeNotifierProvider.autoDispose<ArtistAnalyticsController>(
  (ref) => ArtistAnalyticsController(),
);

class ArtistAnalyticsController extends ChangeNotifier with Buffers {
  String _artistName = '';
  String get artistName => _artistName;

  AnalyticsPeriod selectedPeriod = AnalyticsPeriod.sevenDays;

  List<AnalyticsStatEntity> _stats = const [
    AnalyticsStatEntity(
      icon: AppAssetsPng.analyticsPlaysIcn,
      value: '0',
      label: 'Total Plays',
      change: '',
      isPositive: true,
    ),
    AnalyticsStatEntity(
      icon: AppAssetsPng.analyticsSavesIcn,
      value: '0',
      label: 'Total Saves',
      change: '',
      isPositive: true,
    ),
    AnalyticsStatEntity(
      icon: AppAssetsPng.analyticsYesNoIcn,
      value: '0',
      label: 'Likes',
      change: '',
      isPositive: true,
    ),
    AnalyticsStatEntity(
      icon: AppAssetsPng.analyticsListenersIcn,
      value: '0',
      label: 'Total Comments',
      change: '',
      isPositive: true,
    ),
  ];
  List<AnalyticsStatEntity> get stats => _stats;

  List<AnalyticsGenreEntity> _genreData = [];
  List<AnalyticsGenreEntity> get genreData => _genreData;

  List<AnalyticsTopTrackEntity> _topTracks = [];
  List<AnalyticsTopTrackEntity> get topTracks => _topTracks;

  AnalyticsChartDataEntity _chartData = const AnalyticsChartDataEntity(
    values: [0],
    xLabels: [''],
  );
  AnalyticsChartDataEntity get chartData => _chartData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic> _rawDailyPlays = {};
  int _totalPlays = 0;
  int _totalSaves = 0;
  int _totalLikes = 0;
  int _totalComments = 0;

  ArtistAnalyticsController() {
    fetchArtistName();
    fetchAnalytics();
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
      appPrint('[Analytics] Error fetching artist name: $e');
    }
  }

  Future<void> fetchAnalytics() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await locator<FirestoreService>().getArtistAnalytics();
      if (data != null) {
        _totalPlays = data['totalPlays'] ?? 0;
        _totalSaves = data['totalSaves'] ?? 0;
        _totalLikes = data['totalLikes'] ?? 0;
        _totalComments = data['totalComments'] ?? 0;

        _updateStats();

        final topTracksList = data['topTracks'] as List<dynamic>? ?? [];
        _topTracks = topTracksList.asMap().entries.map((entry) {
          final t = entry.value as Map<String, dynamic>;
          return AnalyticsTopTrackEntity(
            rank: entry.key + 1,
            title: t['title'] ?? '',
            plays: t['plays'] ?? 0,
            saves: t['saves'] ?? 0,
            likes: t['likes'] ?? 0,
          );
        }).toList();

        final genreBreakdown = data['genreBreakdown'] as List<dynamic>? ?? [];
        _genreData = genreBreakdown.map((g) {
          final genreMap = g as Map<String, dynamic>;
          return AnalyticsGenreEntity(
            genre: genreMap['genre'] ?? '',
            value: (genreMap['count'] ?? 0).toDouble(),
          );
        }).toList();

        _rawDailyPlays = data['dailyPlays'] as Map<String, dynamic>? ?? {};
        _updateChartData();
      }
    } catch (e) {
      appPrint('[Analytics] Error fetching analytics: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _updateStats() {
    _stats = [
      AnalyticsStatEntity(
        icon: AppAssetsPng.analyticsPlaysIcn,
        value: _totalPlays.toString(),
        label: 'Total Plays',
        change: '',
        isPositive: true,
      ),
      AnalyticsStatEntity(
        icon: AppAssetsPng.analyticsSavesIcn,
        value: _totalSaves.toString(),
        label: 'Total Saves',
        change: '',
        isPositive: true,
      ),
      AnalyticsStatEntity(
        icon: AppAssetsPng.analyticsYesNoIcn,
        value: _totalLikes.toString(),
        label: 'Likes',
        change: '',
        isPositive: true,
      ),
      AnalyticsStatEntity(
        icon: AppAssetsPng.analyticsListenersIcn,
        value: _totalComments.toString(),
        label: 'Total Comments',
        change: '',
        isPositive: true,
      ),
    ];
  }

  void _updateChartData() {
    final sortedDays = _rawDailyPlays.keys.toList()..sort();

    int daysToShow;
    switch (selectedPeriod) {
      case AnalyticsPeriod.sevenDays:
        daysToShow = 7;
        break;
      case AnalyticsPeriod.thirtyDays:
        daysToShow = 30;
        break;
      case AnalyticsPeriod.allTime:
        daysToShow = sortedDays.length;
        break;
    }

    final recentDays = sortedDays.length > daysToShow
        ? sortedDays.sublist(sortedDays.length - daysToShow)
        : sortedDays;

    final values = <double>[];
    for (final d in recentDays) {
      values.add((_rawDailyPlays[d] as num? ?? 0).toDouble());
    }

    _chartData = AnalyticsChartDataEntity(
      values: values,
      xLabels: recentDays.map<String>((d) => d.substring(5)).toList(),
    );
  }

  void selectPeriod(AnalyticsPeriod period) {
    if (selectedPeriod == period) return;
    selectedPeriod = period;
    _updateChartData();
    notifyListeners();
  }
}
