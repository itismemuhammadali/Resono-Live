import 'dart:async';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
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

      cards.clear();
      for (final p in performances) {
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

        final thumbnailUrl = (p['thumbnailUrl'] ?? '').toString();
        final title = (p['title'] ?? '').toString();
        final description = (p['description'] ?? '').toString();
        final genres = p['genres'] is List ? (p['genres'] as List).cast<String>() : <String>[];
        final viewersCount = p['viewers_count'] ?? 0;
        final likesCount = p['likes_count'] ?? 0;

        final formattedViews = _formatCount(viewersCount);

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

  void swipe({required bool liked}) {
    if (currentIndex >= cards.length) return;
    final card = cards[currentIndex];
    cardRatings[currentIndex] = liked;

    if (card.performanceId.isNotEmpty) {
      if (liked) {
        locator<FirestoreService>().likePerformance(performanceId: card.performanceId);
      }
    }

    // Auto-advance to next card on dislike
    if (!liked && currentIndex < cards.length - 1) {
      currentIndex++;
    }

    notifyListeners();

    // Clear the swipe overlay after 2 seconds
    _swipeTimer?.cancel();
    _swipeTimer = Timer(const Duration(seconds: 2), () {
      if (currentIndex < cards.length) {
        cardRatings.remove(currentIndex);
        notifyListeners();
      }
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
}
