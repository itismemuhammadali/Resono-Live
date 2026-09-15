import 'dart:async';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/core/services/community_firestore_service.dart';
import 'package:vibe_swipe/src/core/services/safety_service.dart';
import 'package:vibe_swipe/src/modules/artist/community/domain/entities/community_post_entity.dart';

final listenerCommunityControllerProvider =
    ChangeNotifierProvider.autoDispose<ListenerCommunityController>(
      (ref) => ListenerCommunityController(),
    );

class ListenerCommunityController extends ChangeNotifier with Buffers {
  // Create Post
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  bool _categoryError = false;
  bool get categoryError => _categoryError;

  bool _isPublishing = false;
  bool get isPublishing => _isPublishing;

  String _username = '';
  String get username => _username;

  String _avatarUrl = '';
  String get avatarUrl => _avatarUrl;


  static const postCategories = [
    'General Discussion',
    'Artist Talk',
    'Feedback',
    'New Releases',
    'Performances',
    'Production Tips',
    'Help & Support',
  ];

  final Set<String> _selectedCategories = {};
  Set<String> get selectedCategories => Set.unmodifiable(_selectedCategories);

  // Live posts from Firestore
  StreamSubscription<List<CommunityPost>>? _allPostsSubscription;
  StreamSubscription<List<CommunityPost>>? _recentPostsSubscription;
  List<CommunityPostEntity> _allPosts = [];
  List<CommunityPostEntity> get allPosts => _allPosts;
  List<CommunityPostEntity> _recentPosts = [];
  List<CommunityPostEntity> get recentPosts => _recentPosts;

  final Map<String, String> _avatarCache = {};

  Future<String> _getAuthorAvatar(String authorId) async {
    if (_avatarCache.containsKey(authorId)) return _avatarCache[authorId]!;
    try {
      final data = await locator<FirestoreService>().getUserProfileById(authorId);
      final url = (data?['profileImageUrl'] ?? data?['avatarUrl'] ?? data?['profileImage'] ?? '').toString();
      _avatarCache[authorId] = url;
      return url;
    } catch (e) {
      _avatarCache[authorId] = '';
      return '';
    }
  }

  bool _isLoadingPosts = true;
  bool get isLoadingPosts => _isLoadingPosts;

  ListenerCommunityController() {
    titleController.addListener(notifyListeners);
    contentController.addListener(notifyListeners);
    _fetchUsername();
    _listenToAllPosts();
    _listenToRecentPosts();
    SafetyService.safetyNotifier.addListener(_onSafetyChanged);
  }

  void _onSafetyChanged() {
    final reported = SafetyService.cachedReportedPostIds;
    final blocked = SafetyService.cachedBlockedUserIds;
    _allPosts = _allPosts.where((p) => !reported.contains(p.id) && !blocked.contains(p.authorId)).toList();
    _recentPosts = _recentPosts.where((p) => !reported.contains(p.id) && !blocked.contains(p.authorId)).toList();
    notifyListeners();
  }

  Future<void> _fetchUsername() async {
    try {
      final uid = locator<FirebaseAuthService>().getUid();
      if (uid == null) return;
      final data = await locator<FirestoreService>().getUserData(uid);
      if (data != null) {
        _username = (data['username'] ?? data['name'] ?? 'Listener').toString();
        _avatarUrl = (data['profileImageUrl'] ?? data['avatarUrl'] ?? data['profileImage'] ?? '').toString();
        notifyListeners();
      }
    } catch (e) {
      appPrint('[Community] Error fetching username: $e');
    }
  }

  void toggleCategory(String category) {
    _selectedCategories.contains(category)
        ? _selectedCategories.remove(category)
        : _selectedCategories.add(category);
    if (_categoryError && _selectedCategories.isNotEmpty) {
      _categoryError = false;
    }
    notifyListeners();
  }

  void onPublish() async {
    final formValid = formKey.currentState?.validate() ?? false;
    final hasCategory = _selectedCategories.isNotEmpty;
    if (!hasCategory) {
      _categoryError = true;
      notifyListeners();
    }
    if (!formValid || !hasCategory || _isPublishing) return;

    _isPublishing = true;
    notifyListeners();

    try {
      final uid = locator<FirebaseAuthService>().getUid();
      if (uid == null) throw Exception('Not authenticated');

      await CommunityFirestoreService.createPost(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        category: _selectedCategories.first,
        authorId: uid,
        authorName: _username,
        authorRole: 'listener',
        authorAvatarUrl: _avatarUrl,
      );


      titleController.clear();
      contentController.clear();
      _selectedCategories.clear();

      AppRouterGo.back();
    } catch (e) {
      appPrint('[Community] Error publishing post: $e');
    } finally {
      _isPublishing = false;
      notifyListeners();
    }
  }

  void _listenToAllPosts() {
    _allPostsSubscription = CommunityFirestoreService.watchAllPosts().listen(
      (posts) async {
        final entities = <CommunityPostEntity>[];
        for (final p in posts) {
          final avatar = await _getAuthorAvatar(p.authorId);
          entities.add(CommunityPostEntity(
            id: p.id,
            title: p.title,
            subtitle: p.content,
            content: p.content,
            category: p.category,
            authorId: p.authorId,
            authorName: p.authorName,
            authorRole: p.authorRole,
            authorAvatarUrl: avatar,
            likes: p.likesCount,
            comments: p.repliesCount,
            date: p.timeAgo,
            createdAt: p.createdAt,
          ));
        }
        _allPosts = entities;
        _isLoadingPosts = false;
        notifyListeners();
      },
      onError: (e) {
        appPrint('[Community] Error listening to posts: $e');
        _isLoadingPosts = false;
        notifyListeners();
      },
    );
  }

  void _listenToRecentPosts() {
    _recentPostsSubscription = CommunityFirestoreService.watchRecentPosts(limit: 3).listen(
      (posts) async {
        final entities = <CommunityPostEntity>[];
        for (final p in posts) {
          final avatar = await _getAuthorAvatar(p.authorId);
          entities.add(CommunityPostEntity(
            id: p.id,
            title: p.title,
            subtitle: p.content,
            content: p.content,
            category: p.category,
            authorId: p.authorId,
            authorName: p.authorName,
            authorRole: p.authorRole,
            authorAvatarUrl: avatar,
            likes: p.likesCount,
            comments: p.repliesCount,
            date: p.timeAgo,
            createdAt: p.createdAt,
          ));
        }
        _recentPosts = entities;
        notifyListeners();
      },
      onError: (e) {
        appPrint('[Community] Error listening to recent posts: $e');
      },
    );
  }

  void onCancel() => AppRouterGo.back();

  // Genre Community Detail
  int selectedFilter = 0;
  bool isTrending = true;

  static const filters = ['All', 'Production', 'Discussion', 'Feedback'];

  List<CommunityPostEntity> get trendingPosts => _allPosts
      .where((p) => p.content.isNotEmpty)
      .toList()
    ..sort((a, b) => b.likes.compareTo(a.likes));

  List<CommunityPostEntity> get latestPosts =>
      List<CommunityPostEntity>.from(_allPosts);

  List<CommunityPostEntity> get posts => isTrending ? trendingPosts : latestPosts;

  void setFilter(int index) {
    selectedFilter = index;
    notifyListeners();
  }

  void setTrending(bool value) {
    isTrending = value;
    notifyListeners();
  }

  // Discussion Detail — replies fetched from Firestore
  List<Map<String, dynamic>> _replies = [];
  List<Map<String, dynamic>> get replies => _replies;

  final replyController = TextEditingController();

  void postReply() async {
    final text = replyController.text.trim();
    if (text.isEmpty) return;

    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null) return;

    try {
      await CommunityFirestoreService.createPost(
        title: '',
        content: text,
        category: 'Reply',
        authorId: uid,
        authorName: _username,
        authorRole: 'listener',
        authorAvatarUrl: _avatarUrl,
      );

      replyController.clear();
    } catch (e) {
      appPrint('[Community] Error posting reply: $e');
    }
  }

  // Discussion detail state
  String _currentPostId = '';
  bool _isDiscussionLiked = false;
  bool get isDiscussionLiked => _isDiscussionLiked;

  int _discussionLikeCount = 0;
  int get discussionLikeCount => _discussionLikeCount;

  List<CommunityComment> _discussionComments = [];
  List<CommunityComment> get discussionComments => _discussionComments;

  StreamSubscription<List<CommunityComment>>? _commentsSubscription;
  StreamSubscription<CommunityPost?>? _currentPostSubscription;

  Stream<CommunityPost?> get currentPostStream =>
      _currentPostId.isNotEmpty
          ? CommunityFirestoreService.watchPost(_currentPostId)
          : const Stream.empty();

  String _discussionAuthorAvatar = '';
  String get discussionAuthorAvatar => _discussionAuthorAvatar;

  void initDiscussion(String postId, {String initialAvatar = ''}) {
    if (_currentPostId == postId) return;
    _currentPostId = postId;
    _discussionAuthorAvatar = initialAvatar;

    _commentsSubscription?.cancel();
    final uid = locator<FirebaseAuthService>().getUid();
    _commentsSubscription = CommunityFirestoreService.watchComments(postId).listen(
      (comments) {
        _discussionComments = comments;
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
        appPrint('[Community] Error watching comments: $e');
      },
    );

    _currentPostSubscription?.cancel();
    _currentPostSubscription = CommunityFirestoreService.watchPost(postId).listen(
      (post) async {
        if (post == null) return;
        _discussionLikeCount = post.likesCount;
        if (uid != null) {
          _isDiscussionLiked = post.likedBy.contains(uid);
        }
        final avatar = await _getAuthorAvatar(post.authorId);
        _discussionAuthorAvatar = avatar;
        notifyListeners();
      },
      onError: (e) {
        appPrint('[Community] Error watching post: $e');
      },
    );
  }


  void setDiscussionLikeStatus(bool isLiked) {
    _isDiscussionLiked = isLiked;
    notifyListeners();
  }

  // Comment-level likes
  final Set<String> _likedCommentIds = {};

  bool isCommentLiked(String commentId) => _likedCommentIds.contains(commentId);

  void toggleCommentLike(String commentId) async {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null || _currentPostId.isEmpty) return;

    final wasLiked = _likedCommentIds.contains(commentId);
    if (wasLiked) {
      _likedCommentIds.remove(commentId);
    } else {
      _likedCommentIds.add(commentId);
    }
    notifyListeners();

    try {
      await CommunityFirestoreService.toggleCommentLike(_currentPostId, commentId, uid);
    } catch (e) {
      if (wasLiked) {
        _likedCommentIds.add(commentId);
      } else {
        _likedCommentIds.remove(commentId);
      }
      notifyListeners();
      appPrint('[Community] Error toggling comment like: $e');
    }
  }

  void toggleDiscussionLike() async {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null || _currentPostId.isEmpty) return;

    final previousLiked = _isDiscussionLiked;
    final previousCount = _discussionLikeCount;

    _isDiscussionLiked = !_isDiscussionLiked;
    _discussionLikeCount += _isDiscussionLiked ? 1 : -1;
    notifyListeners();

    try {
      await CommunityFirestoreService.toggleLike(_currentPostId, uid);
    } catch (e) {
      _isDiscussionLiked = previousLiked;
      _discussionLikeCount = previousCount;
      notifyListeners();
      appPrint('[Community] Error toggling like: $e');
    }
  }

  void postDiscussionComment(String text) async {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null || text.trim().isEmpty || _currentPostId.isEmpty) return;

    try {
      final data = await locator<FirestoreService>().getUserData(uid);
      final authorName = (data?['username'] ?? data?['name'] ?? 'Listener').toString();
      final authorRole = (data?['role'] ?? 'listener').toString();
      final authorAvatarUrl = (data?['profileImageUrl'] ?? data?['avatarUrl'] ?? '').toString();

      await CommunityFirestoreService.postComment(
        postId: _currentPostId,
        authorId: uid,
        authorName: authorName,
        authorRole: authorRole,
        authorAvatarUrl: authorAvatarUrl,
        text: text.trim(),
      );
    } catch (e) {
      appPrint('[Community] Error posting comment: $e');
    }
  }

  @override
  void dispose() {
    SafetyService.safetyNotifier.removeListener(_onSafetyChanged);
    _allPostsSubscription?.cancel();
    _recentPostsSubscription?.cancel();
    _commentsSubscription?.cancel();
    _currentPostSubscription?.cancel();
    titleController.dispose();
    contentController.dispose();
    replyController.dispose();
    super.dispose();
  }
}
