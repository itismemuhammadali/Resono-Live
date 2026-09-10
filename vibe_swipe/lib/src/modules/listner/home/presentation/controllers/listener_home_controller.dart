import 'dart:async';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/core/services/safety_service.dart';
import '../../domain/entities/post_card_entity.dart';

final listenerHomeControllerProvider =
    ChangeNotifierProvider.autoDispose<ListenerHomeController>(
      (ref) => ListenerHomeController(),
    );

class ListenerHomeController extends ChangeNotifier with Buffers {
  int selectedFilter = 0;
  Offset dragOffset = Offset.zero;
  int currentIndex = 0;
  final Map<int, bool> cardRatings = {};
  Timer? _swipeTimer;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  final List<PostCardEntity> cards = [];

  ListenerHomeController() {
    fetchCards();
  }

  int get currentCardSwipeDirection {
    final rating = cardRatings[currentIndex];
    if (rating == null) return 0;
    return rating ? 1 : -1;
  }

  void togglePlay() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  Future<void> fetchCards() async {
    _isLoading = true;
    notifyListeners();

    try {
      final performances = await locator<FirestoreService>().getPerformances(
        limit: 20,
      );
      final restrictedArtistIds = await SafetyService.getBlockedAndBannedArtistIds();

      cards.clear();
      for (final p in performances) {
        final artistId = p['artist_id'] as String? ?? '';
        if (artistId.isNotEmpty && restrictedArtistIds.contains(artistId)) {
          continue;
        }
        String artistName = 'Unknown Artist';
        String artistImageUrl = '';

        if (artistId.isNotEmpty) {
          final artistData = await locator<FirestoreService>().getUserProfileById(artistId);
          if (artistData != null) {
            artistName = (artistData['artistName'] ?? artistData['name'] ?? 'Unknown Artist').toString();
            artistImageUrl = (artistData['profileImageUrl'] ?? '').toString();
          }
        }

        final thumbnailUrl = (p['thumbnailUrl'] ?? '').toString();
        final title = (p['title'] ?? '').toString();
        final description = (p['description'] ?? '').toString();
        final genres = p['genres'] is List ? (p['genres'] as List).cast<String>() : <String>[];
        final likesCount = p['likes_count'] ?? 0;

        cards.add(PostCardEntity(
          name: artistName,
          caption: description.isNotEmpty ? description : title,
          song: genres.isNotEmpty ? genres.first : 'Music',
          likes: _formatCount(likesCount),
          imageUrl: thumbnailUrl.isNotEmpty
              ? thumbnailUrl
              : 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=600&q=80',
          artistId: artistId,
          artistImageUrl: artistImageUrl,
          performanceId: p['id'] as String? ?? '',
          title: title,
          status: (p['status'] ?? 'upcoming').toString(),
          videoUrl: (p['videoUrl'] ?? '').toString(),
          type: (p['type'] ?? 'live').toString(),
        ));
      }

      if (cards.isEmpty) {
        cards.addAll(_defaultSampleCards);
      }

      _isLoading = false;
      notifyListeners();

      // Fetch follow state for all unique artists
      final uniqueArtistIds = cards.map((c) => c.artistId).where((id) => id.isNotEmpty).toSet();
      for (final artistId in uniqueArtistIds) {
        final data = await locator<FirestoreService>().getFollowState(artistId: artistId);
        if (data != null && data['isFollowing'] == true) {
          _followedArtistIds.add(artistId);
        }
      }
      notifyListeners();
    } catch (e) {
      appPrint('[Home] Error fetching cards: $e');
      if (cards.isEmpty) {
        cards.addAll(_defaultSampleCards);
      }
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

  void onFilterSelected(int index) {
    selectedFilter = index;
    notifyListeners();
  }

  void onDragUpdate(DragUpdateDetails details) {
    dragOffset += details.delta;
    notifyListeners();
  }

  void onDragEnd(DragEndDetails details) {
    const threshold = 100.0;
    if (dragOffset.dx < -threshold && currentIndex < cards.length - 1) {
      currentIndex++;
    } else if (dragOffset.dx > threshold && currentIndex > 0) {
      currentIndex--;
    }
    dragOffset = Offset.zero;
    notifyListeners();
  }

  void onPageChanged(int index) {
    if (currentIndex != index) {
      currentIndex = index;
      notifyListeners();
    }
  }

  void swipe({required bool liked}) {
    if (currentIndex >= cards.length) return;
    final card = cards[currentIndex];
    final targetIndex = currentIndex;
    cardRatings[targetIndex] = liked;

    if (card.performanceId.isNotEmpty) {
      if (liked) {
        locator<FirestoreService>().likePerformance(performanceId: card.performanceId);
      }
    }

    notifyListeners();

    // Clear the swipe overlay after 2 seconds
    _swipeTimer?.cancel();
    _swipeTimer = Timer(const Duration(seconds: 2), () {
      cardRatings.remove(targetIndex);
      notifyListeners();
    });
  }

  final Set<int> _bookmarkedIndices = {};
  bool isBookmarked(int index) => _bookmarkedIndices.contains(index);

  final Set<String> _followedArtistIds = {};
  bool isFollowed(String artistId) => _followedArtistIds.contains(artistId);

  Future<void> toggleBookmark(int index) async {
    if (index >= cards.length) return;
    final card = cards[index];

    if (_bookmarkedIndices.contains(index)) {
      _bookmarkedIndices.remove(index);
    } else {
      _bookmarkedIndices.add(index);
    }

    if (card.performanceId.isNotEmpty) {
      final data = await locator<FirestoreService>().savePerformance(performanceId: card.performanceId);
      if (data != null) {
        if (data['saved'] == true) {
          _bookmarkedIndices.add(index);
        } else {
          _bookmarkedIndices.remove(index);
        }
      }
    }

    notifyListeners();
  }

  Future<void> toggleFollow(int index) async {
    if (index >= cards.length) return;
    final card = cards[index];
    if (card.artistId.isEmpty) return;

    if (_followedArtistIds.contains(card.artistId)) {
      _followedArtistIds.remove(card.artistId);
    } else {
      _followedArtistIds.add(card.artistId);
    }
    notifyListeners();

    await locator<FirestoreService>().toggleFollow(artistId: card.artistId);
  }

  static const List<PostCardEntity> _defaultSampleCards = [
    PostCardEntity(
      name: 'Luna Ray',
      caption: 'Late night acoustic sessions and vocal loop layering ✨',
      song: 'Indie Pop',
      likes: '12.4K',
      imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=600&q=80',
      artistId: 'sample_artist_1',
      artistImageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
      performanceId: 'sample_perf_1',
      title: 'Midnight Echoes (Live Acoustic)',
      status: 'live',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      type: 'live',
    ),
    PostCardEntity(
      name: 'The Neon Echoes',
      caption: 'Live synthwave jam straight from the studio rooftop 🌆',
      song: 'Electronic',
      likes: '28.1K',
      imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&q=80',
      artistId: 'sample_artist_2',
      artistImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
      performanceId: 'sample_perf_2',
      title: 'Electric Skyline - Live Rooftop Set',
      status: 'upcoming',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      type: 'live',
    ),
    PostCardEntity(
      name: 'Marcus Bell',
      caption: 'Improv jazz solo & soulful saxophone vibes 🎷',
      song: 'Jazz & Soul',
      likes: '9.8K',
      imageUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&q=80',
      artistId: 'sample_artist_3',
      artistImageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
      performanceId: 'sample_perf_3',
      title: 'Blue Note Midnight Jam',
      status: 'live',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      type: 'live',
    ),
    PostCardEntity(
      name: 'Aria Cruz',
      caption: 'High energy beats, heavy 808s and fast verses 🔥',
      song: 'Hip Hop',
      likes: '45.2K',
      imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600&q=80',
      artistId: 'sample_artist_4',
      artistImageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
      performanceId: 'sample_perf_4',
      title: 'Cypher Volume 3 - Live Drop',
      status: 'upcoming',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      type: 'live',
    ),
  ];

  /// Instantly removes all performance cards belonging to an artist (e.g. upon block/report)
  void removeCardsForArtist(String artistId) {
    if (artistId.isEmpty) return;
    cards.removeWhere((c) => c.artistId == artistId);
    notifyListeners();
  }
}
