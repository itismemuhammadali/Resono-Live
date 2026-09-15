import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/core/constants/app_constants.dart';
import 'package:vibe_swipe/src/core/services/community_firestore_service.dart';
import 'package:vibe_swipe/src/core/services/safety_service.dart';
import '../../domain/entities/community_activity_entity.dart';
import '../../domain/entities/community_discussion_entity.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/entities/community_topic_entity.dart';

final artistCommunityControllerProvider = ChangeNotifierProvider.autoDispose(
  (ref) => ArtistCommunityController(),
);

class ArtistCommunityController extends ChangeNotifier with Buffers {
  // Create Post
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  bool _isPublishing = false;
  bool get isPublishing => _isPublishing;

  bool get canPublish =>
      titleController.text.trim().isNotEmpty &&
      contentController.text.trim().isNotEmpty;

  String _artistName = '';
  String get artistName => _artistName;

  String _artistAvatarUrl = '';
  String get artistAvatarUrl => _artistAvatarUrl;


  StreamSubscription<List<CommunityPost>>? _postsSubscription;
  List<CommunityPostEntity> _yourPosts = [];
  List<CommunityPostEntity> get yourPosts => _yourPosts;

  bool _isLoadingPosts = true;
  bool get isLoadingPosts => _isLoadingPosts;

  ArtistCommunityController() {
    titleController.addListener(notifyListeners);
    contentController.addListener(notifyListeners);
    fetchArtistName();
    _fetchAvailableTracks();
    _fetchAvailablePerformances();
    _listenToMyPosts();
    _listenToAllPosts();
    SafetyService.safetyNotifier.addListener(_onSafetyChanged);
  }

  void _onSafetyChanged() {
    final reported = SafetyService.cachedReportedPostIds;
    final blocked = SafetyService.cachedBlockedUserIds;
    _allPosts = _allPosts.where((p) => !reported.contains(p.id) && !blocked.contains(p.authorId)).toList();
    _yourPosts = _yourPosts.where((p) => !reported.contains(p.id) && !blocked.contains(p.authorId)).toList();
    _deriveTrendingDiscussions();
    _deriveTrendingTopics();
    _deriveRecentActivity();
    notifyListeners();
  }

  Future<void> _fetchAvailableTracks() async {
    // TODO: Implement when tracks collection is added to Firestore
    _availableTracks = [];
    notifyListeners();
  }

  Future<void> _fetchAvailablePerformances() async {
    try {
      final uid = locator<FirebaseAuthService>().getUid();
      if (uid == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('performances')
          .where('artist_id', isEqualTo: uid)
          .get();

      _availablePerformances = snapshot.docs
          .map((doc) => (doc.data()['title'] ?? '').toString())
          .where((t) => t.isNotEmpty)
          .toList();
      notifyListeners();
    } catch (e) {
      appPrint('[Community] Error fetching performances: $e');
    }
  }

  Future<void> fetchArtistName() async {
    try {
      final uid = locator<FirebaseAuthService>().getUid();
      if (uid == null) return;
      final data = await locator<FirestoreService>().getUserData(uid);
      if (data != null) {
        _artistName = (data['artistName'] ?? data['name'] ?? '').toString();
        _artistAvatarUrl = (data['profileImageUrl'] ?? data['avatarUrl'] ?? data['profileImage'] ?? '').toString();
        notifyListeners();
      }
    } catch (e) {
      appPrint('[Community] Error fetching artist name: $e');
    }
  }


  ArtistPostLinkType _linkType = ArtistPostLinkType.none;
  ArtistPostLinkType get linkType => _linkType;

  String? _selectedTrack;
  String? get selectedTrack => _selectedTrack;

  String? _selectedPerformance;
  String? get selectedPerformance => _selectedPerformance;

  List<String> _availableTracks = [];
  List<String> get availableTracks => _availableTracks;

  List<String> _availablePerformances = [];
  List<String> get availablePerformances => _availablePerformances;

  void setLinkType(ArtistPostLinkType type) {
    _linkType = type;
    notifyListeners();
  }

  void selectTrack(String? track) {
    _selectedTrack = track;
    notifyListeners();
  }

  void selectPerformance(String? performance) {
    _selectedPerformance = performance;
    notifyListeners();
  }

  void onPublishPost() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (_isPublishing) return;

    _isPublishing = true;
    notifyListeners();

    try {
      final uid = locator<FirebaseAuthService>().getUid();
      if (uid == null) throw Exception('Not authenticated');

      await CommunityFirestoreService.createPost(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        category: 'General',
        authorId: uid,
        authorName: _artistName,
        authorRole: 'artist',
        authorAvatarUrl: _artistAvatarUrl,
      );


      titleController.clear();
      contentController.clear();
      _linkType = ArtistPostLinkType.none;
      _selectedTrack = null;
      _selectedPerformance = null;

      AppRouterGo.back();
    } catch (e) {
      appPrint('[Community] Error publishing post: $e');
    } finally {
      _isPublishing = false;
      notifyListeners();
    }
  }

  void _listenToMyPosts() {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null) return;

    _postsSubscription = CommunityFirestoreService.watchPostsByAuthor(uid).listen(
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
            date: '${p.createdAt.month}/${p.createdAt.day}/${p.createdAt.year}',
            createdAt: p.createdAt,
          ));
        }
        _yourPosts = entities;
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

  // Community — derived from Firestore

  StreamSubscription<List<CommunityPost>>? _allPostsSubscription;
  List<CommunityPostEntity> _allPosts = [];

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

  List<CommunityDiscussionEntity> _trendingDiscussions = [];
  List<CommunityDiscussionEntity> get trendingDiscussions => _trendingDiscussions;

  List<CommunityTopicEntity> _trendingTopics = [];
  List<CommunityTopicEntity> get trendingTopics => _trendingTopics;

  List<CommunityActivityEntity> _recentActivity = [];
  List<CommunityActivityEntity> get recentActivity => _recentActivity;

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
        _deriveTrendingDiscussions();
        _deriveTrendingTopics();
        _deriveRecentActivity();
        notifyListeners();
      },
      onError: (e) {
        appPrint('[Community] Error listening to all posts: $e');
      },
    );
  }

  void _deriveTrendingDiscussions() {
    _trendingDiscussions = _allPosts
        .where((p) => p.content.isNotEmpty)
        .take(5)
        .map((p) => CommunityDiscussionEntity(
              id: p.id,
              title: p.title,
              author: p.authorName,
              authorId: p.authorId,
              replies: p.comments,
              likes: p.likes,
              date: p.date,
              content: p.content,
            ))
        .toList();
  }

  void _deriveTrendingTopics() {
    final Map<String, int> categoryCounts = {};
    for (final post in _allPosts) {
      if (post.category.isNotEmpty) {
        categoryCounts[post.category] = (categoryCounts[post.category] ?? 0) + 1;
      }
    }

    _trendingTopics = categoryCounts.entries
        .take(4)
        .toList()
        .asMap()
        .entries
        .map((entry) => CommunityTopicEntity(
              title: entry.value.key,
              count: '${entry.value.value} discussions',
              changePercent: '',
              asset: AppConstants.trendingTopicAssets[entry.key % AppConstants.trendingTopicAssets.length],
            ))
        .toList();
  }

  void _deriveRecentActivity() {
    _recentActivity = _allPosts.take(4).map((p) => CommunityActivityEntity(
          actor: p.authorName,
          action: 'posted "${p.title}"',
          timeAgo: p.date,
          asset: 'assets/icons/png/artist_community_trending_discussions.png',
        )).toList();
  }

  @override
  void dispose() {
    SafetyService.safetyNotifier.removeListener(_onSafetyChanged);
    _postsSubscription?.cancel();
    _allPostsSubscription?.cancel();
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
