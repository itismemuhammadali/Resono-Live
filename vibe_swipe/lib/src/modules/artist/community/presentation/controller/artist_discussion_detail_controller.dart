import 'dart:async';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/core/services/community_firestore_service.dart';

final artistDiscussionDetailControllerProvider =
    ChangeNotifierProvider.autoDispose.family<ArtistDiscussionDetailController, String>(
  (ref, postId) => ArtistDiscussionDetailController(postId),
);

class ArtistDiscussionDetailController extends ChangeNotifier {
  ArtistDiscussionDetailController(this._postId) {
    _init();
  }

  final String _postId;

  bool _isLiked = false;
  bool get isLiked => _isLiked;

  int _likeCount = 0;
  int get likeCount => _likeCount;

  List<CommunityComment> _comments = [];
  List<CommunityComment> get comments => _comments;

  StreamSubscription<List<CommunityComment>>? _commentsSubscription;

  final Set<String> _likedCommentIds = {};

  bool isCommentLiked(String commentId) => _likedCommentIds.contains(commentId);

  void _init() {
    final uid = locator<FirebaseAuthService>().getUid();
    _commentsSubscription = CommunityFirestoreService.watchComments(_postId).listen(
      (comments) {
        _comments = comments;
        _likedCommentIds.clear();
        if (uid != null) {
          for (final c in comments) {
            if (c.likedBy.contains(uid)) {
              _likedCommentIds.add(c.id);
            }
          }
        }
        notifyListeners();
      },
      onError: (e) {
        appPrint('[DiscussionDetail] Error watching comments: $e');
      },
    );
    _checkLikeStatus();
  }

  void _checkLikeStatus() async {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null) return;

    try {
      final doc = await CommunityFirestoreService.getPost(_postId);
      if (doc != null) {
        _likeCount = doc.likesCount;
        _isLiked = doc.likedBy.contains(uid);
        notifyListeners();
      }
    } catch (e) {
      appPrint('[DiscussionDetail] Error checking like status: $e');
    }
  }

  void setInitialData({required int likes, required bool isLiked}) {
    _likeCount = likes;
    _isLiked = isLiked;
    notifyListeners();
  }

  Future<void> toggleLike() async {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null) return;

    final previousLiked = _isLiked;
    final previousCount = _likeCount;

    _isLiked = !_isLiked;
    _likeCount += _isLiked ? 1 : -1;
    notifyListeners();

    try {
      final result = await CommunityFirestoreService.toggleLike(_postId, uid);
      _isLiked = result;
      _likeCount = result ? previousCount + 1 : previousCount - 1;
      notifyListeners();
    } catch (e) {
      _isLiked = previousLiked;
      _likeCount = previousCount;
      notifyListeners();
      appPrint('[DiscussionDetail] Error toggling like: $e');
    }
  }

  void toggleCommentLike(String commentId) async {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null) return;

    final wasLiked = _likedCommentIds.contains(commentId);
    if (wasLiked) {
      _likedCommentIds.remove(commentId);
    } else {
      _likedCommentIds.add(commentId);
    }
    notifyListeners();

    try {
      await CommunityFirestoreService.toggleCommentLike(_postId, commentId, uid);
    } catch (e) {
      if (wasLiked) {
        _likedCommentIds.add(commentId);
      } else {
        _likedCommentIds.remove(commentId);
      }
      notifyListeners();
      appPrint('[DiscussionDetail] Error toggling comment like: $e');
    }
  }

  Future<void> postComment(String text) async {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null || text.trim().isEmpty) return;

    try {
      final data = await locator<FirestoreService>().getUserData(uid);
      final authorName = (data?['artistName'] ?? data?['name'] ?? 'Unknown').toString();
      final authorRole = (data?['role'] ?? 'artist').toString();
      final authorAvatarUrl = (data?['profileImageUrl'] ?? data?['avatarUrl'] ?? '').toString();

      await CommunityFirestoreService.postComment(
        postId: _postId,
        authorId: uid,
        authorName: authorName,
        authorRole: authorRole,
        authorAvatarUrl: authorAvatarUrl,
        text: text.trim(),
      );
    } catch (e) {
      appPrint('[DiscussionDetail] Error posting comment: $e');
    }
  }

  @override
  void dispose() {
    _commentsSubscription?.cancel();
    super.dispose();
  }
}
