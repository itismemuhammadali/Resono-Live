import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/performance_featured_entity.dart';
import '../../domain/entities/performance_upcoming_entity.dart';
import '../../domain/entities/performance_trending_entity.dart';

final listenerPerformancesControllerProvider =
    ChangeNotifierProvider.autoDispose<ListenerPerformancesController>(
      (ref) => ListenerPerformancesController(),
    );

class ListenerPerformancesController extends ChangeNotifier with Buffers {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  PerformanceFeaturedEntity? _featured;
  PerformanceFeaturedEntity get featured => _featured ?? const PerformanceFeaturedEntity(
    title: 'No performances yet',
    artist: 'Browse artists',
    genre: 'Music',
    viewCount: '0',
    isLive: false,
  );

  List<PerformanceUpcomingEntity> _upcomingPerformances = [];
  List<PerformanceUpcomingEntity> get upcomingPerformances => _upcomingPerformances;

  List<PerformanceTrendingEntity> _trendingPerformances = [];
  List<PerformanceTrendingEntity> get trendingPerformances => _trendingPerformances;

  // Video player state
  VideoPlayerController? _videoController;
  VideoPlayerController? get videoController => _videoController;
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  bool _isLiked = false;
  bool get isLiked => _isLiked;
  bool _isSaved = false;
  bool get isSaved => _isSaved;
  bool _isFollowing = false;
  bool get isFollowing => _isFollowing;
  int _likesCount = 0;
  int get likesCount => _likesCount;
  bool _isVideoInitialized = false;
  bool get isVideoInitialized => _isVideoInitialized;
  Duration _videoPosition = Duration.zero;
  Duration get videoPosition => _videoPosition;
  Duration _videoDuration = Duration.zero;
  Duration get videoDuration => _videoDuration;
  String _currentPerformanceId = '';
  String _currentArtistId = '';
  int _fetchGeneration = 0;


  double get videoProgress {
    if (_videoDuration.inMilliseconds == 0) return 0.0;
    return (_videoPosition.inMilliseconds / _videoDuration.inMilliseconds).clamp(0.0, 1.0);
  }

  ListenerPerformancesController() {
    fetchPerformances();
  }

  Future<void> initVideo(String url) async {
    if (url.isEmpty) return;
    await disposeVideo();
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      _videoController!.addListener(_onVideoProgress);
      await _videoController!.initialize();
      _isVideoInitialized = true;
      _videoDuration = _videoController!.value.duration;
      notifyListeners();
      await _videoController!.play();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      appPrint('[Performances] Error initializing video: $e');
      _isVideoInitialized = false;
      notifyListeners();
    }
  }

  void _onVideoProgress() {
    if (_videoController == null) return;
    final newPos = _videoController!.value.position;
    final newDur = _videoController!.value.duration;
    if (_videoPosition != newPos || _videoDuration != newDur) {
      _videoPosition = newPos;
      _videoDuration = newDur;
      notifyListeners();
    }
  }

  Future<void> disposeVideo() async {
    _videoController?.removeListener(_onVideoProgress);
    await _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;
    _isPlaying = false;
    _videoPosition = Duration.zero;
    _videoDuration = Duration.zero;
  }

  void togglePlay() {
    if (_videoController == null || !_isVideoInitialized) return;
    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
      _isPlaying = false;
    } else {
      _videoController!.play();
      _isPlaying = true;
    }
    notifyListeners();
  }

  void seekTo(double progress) {
    if (_videoController == null || !_isVideoInitialized) return;
    final position = Duration(
      milliseconds: (progress * _videoDuration.inMilliseconds).round(),
    );
    _videoController!.seekTo(position);
  }

  void setCurrentPerformance(String id, {String artistId = ''}) {
    _fetchGeneration++;
    final gen = _fetchGeneration;
    _currentPerformanceId = id;
    _currentArtistId = artistId;
    _isLiked = false;
    _isSaved = false;
    _isFollowing = false;
    _likesCount = 0;
    notifyListeners();
    if (id.isNotEmpty) {
      locator<FirestoreService>().recordPerformanceView(performanceId: id);
      _fetchLikeSaveState(id, gen);
    }
    if (artistId.isNotEmpty) {
      _fetchFollowState(artistId, gen);
    }
  }

  Future<void> _fetchLikeSaveState(String performanceId, int gen) async {
    try {
      final data = await locator<FirestoreService>().getPerformanceLikeSaveState(performanceId: performanceId);
      if (gen != _fetchGeneration) return;
      if (data != null) {
        final liked = data['isLiked'];
        final saved = data['isSaved'];
        _isLiked = liked == true;
        _isSaved = saved == true;
        final raw = data['likesCount'] ?? data['likes_count'];
        _likesCount = (raw is num) ? raw.toInt() : 0;
        notifyListeners();
      }
    } catch (e) {
      appPrint('[Performances] Error fetching like/save state: $e');
    }
  }

  Future<void> _fetchFollowState(String artistId, int gen) async {
    try {
      final data = await locator<FirestoreService>().getFollowState(artistId: artistId);
      if (gen != _fetchGeneration) return;
      if (data != null) {
        final following = data['isFollowing'];
        _isFollowing = following == true;
        notifyListeners();
      }
    } catch (e) {
      appPrint('[Performances] Error fetching follow state: $e');
    }
  }

  void toggleLike() {
    _isLiked = !_isLiked;
    _likesCount += _isLiked ? 1 : -1;
    if (_likesCount < 0) _likesCount = 0;
    notifyListeners();
    if (_currentPerformanceId.isNotEmpty) {
      locator<FirestoreService>().likePerformance(performanceId: _currentPerformanceId);
    }
  }

  Future<void> toggleSave() async {
    if (_currentPerformanceId.isEmpty) return;
    _isSaved = !_isSaved;
    notifyListeners();
    final data = await locator<FirestoreService>().savePerformance(performanceId: _currentPerformanceId);
    if (data != null) {
      _isSaved = data['saved'] == true;
      notifyListeners();
    }
  }

  void toggleFollow() {
    _isFollowing = !_isFollowing;
    notifyListeners();
    if (_currentArtistId.isNotEmpty) {
      locator<FirestoreService>().toggleFollow(artistId: _currentArtistId);
    }
  }

  Future<void> fetchPerformances() async {
    _isLoading = true;
    notifyListeners();

    try {
      final allPerformances = await locator<FirestoreService>().getPerformances(limit: 50);

      final upcomingList = <PerformanceUpcomingEntity>[];
      final trendingList = <PerformanceTrendingEntity>[];
      PerformanceFeaturedEntity? firstFeatured;

      for (final p in allPerformances) {
        final artistId = p['artist_id'] as String? ?? '';
        String artistName = 'Unknown Artist';
        String artistImageUrl = '';

        if (artistId.isNotEmpty) {
          final artistData = await locator<FirestoreService>().getUserProfileById(artistId);
          if (artistData != null) {
            artistName = (artistData['artistName'] ?? artistData['name'] ?? 'Unknown Artist').toString();
            artistImageUrl = (artistData['profileImageUrl'] ?? '').toString();
          }
        }

        final title = (p['title'] ?? '').toString();
        final genres = p['genres'] is List ? (p['genres'] as List).cast<String>() : <String>[];
        final genre = genres.isNotEmpty ? genres.first : 'Music';
        final thumbnailUrl = (p['thumbnailUrl'] ?? '').toString();
        final status = (p['status'] ?? 'upcoming').toString();
        final viewersCount = p['viewers_count'] ?? 0;
        final createdAtRaw = p['createdAt'];
        DateTime createdAt = DateTime.now();
        if (createdAtRaw is Timestamp) {
          createdAt = createdAtRaw.toDate();
        } else if (createdAtRaw is String && createdAtRaw.isNotEmpty) {
          createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
        }
        final videoUrl = (p['videoUrl'] ?? '').toString();
        final description = (p['description'] ?? '').toString();

        final formattedViews = _formatCount(viewersCount);

        if (status == 'upcoming') {
          final type = (p['type'] ?? 'live').toString();

          DateTime? scheduledAt;
          final scheduledAtRaw = p['scheduledAt'];
          if (scheduledAtRaw is Timestamp) {
            scheduledAt = scheduledAtRaw.toDate();
          }

          final timeStr = scheduledAt != null
              ? _formatScheduledTime(scheduledAt)
              : _formatTimeAgo(createdAt);

          upcomingList.add(PerformanceUpcomingEntity(
            id: p['id'] as String? ?? '',
            title: title,
            artist: artistName,
            genre: genre,
            time: timeStr,
            thumbnailUrl: thumbnailUrl,
            artistImageUrl: artistImageUrl,
            videoUrl: videoUrl,
            artistId: artistId,
            description: description,
            views: viewersCount,
            type: type,
            scheduledAt: scheduledAt,
          ));
        } else {
          trendingList.add(PerformanceTrendingEntity(
            id: p['id'] as String? ?? '',
            title: title,
            artist: artistName,
            artistId: artistId,
            views: formattedViews,
            thumbnailUrl: thumbnailUrl,
          ));
        }

        if (firstFeatured == null && status != 'pending') {
          firstFeatured = PerformanceFeaturedEntity(
            id: p['id'] as String? ?? '',
            title: title,
            artist: artistName,
            genre: genre,
            viewCount: formattedViews,
            isLive: status == 'live',
            thumbnailUrl: thumbnailUrl,
            videoUrl: videoUrl,
            artistId: artistId,
            artistImageUrl: artistImageUrl,
            description: description,
          );
        }
      }

      _featured = firstFeatured;
      _upcomingPerformances = upcomingList;
      _trendingPerformances = trendingList;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      appPrint('[Performances] Error fetching performances: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatScheduledTime(DateTime scheduled) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledDay = DateTime(scheduled.year, scheduled.month, scheduled.day);

    final hour12 = scheduled.hour == 0 ? 12 : (scheduled.hour > 12 ? scheduled.hour - 12 : scheduled.hour);
    final minute = scheduled.minute.toString().padLeft(2, '0');
    final period = scheduled.hour < 12 ? 'AM' : 'PM';
    final timeStr = '$hour12:$minute $period';

    if (scheduledDay == today) {
      return 'Starts today at $timeStr';
    } else if (scheduledDay == today.add(const Duration(days: 1))) {
      return 'Starts tomorrow at $timeStr';
    } else if (scheduledDay.difference(today).inDays < 7) {
      final dayName = _dayName(scheduled.weekday);
      return 'Starts $dayName at $timeStr';
    } else {
      return '${scheduled.month}/${scheduled.day}/${scheduled.year} at $timeStr';
    }
  }

  String _dayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoProgress);
    _videoController?.dispose();
    super.dispose();
  }
}
