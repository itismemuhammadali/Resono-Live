import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibe_swipe/src/core/utils/app_logger.dart';
import 'package:vibe_swipe/src/core/utils/content_filter.dart';
import 'safety_service.dart';

class CommunityPost {
  final String id;
  final String title;
  final String content;
  final String category;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String authorAvatarUrl;
  final String performanceId;
  final int likesCount;
  final int repliesCount;
  final List<String> likedBy;
  final DateTime createdAt;

  const CommunityPost({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    this.authorAvatarUrl = '',
    this.performanceId = '',
    this.likesCount = 0,
    this.repliesCount = 0,
    this.likedBy = const [],
    required this.createdAt,
  });

  factory CommunityPost.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime createdAtDate = DateTime.now();
    final rawCreated = data['createdAt'];
    if (rawCreated is Timestamp) {
      createdAtDate = rawCreated.toDate();
    } else if (rawCreated is String) {
      createdAtDate = DateTime.tryParse(rawCreated) ?? DateTime.now();
    }
    return CommunityPost(
      id: doc.id,
      title: (data['title'] ?? '').toString(),
      content: (data['content'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
      authorId: (data['authorId'] ?? '').toString(),
      authorName: (data['authorName'] ?? '').toString(),
      authorRole: (data['authorRole'] ?? '').toString(),
      authorAvatarUrl: (data['authorAvatarUrl'] ?? '').toString(),
      performanceId: (data['performanceId'] ?? '').toString(),
      likesCount: (data['likesCount'] as num?)?.toInt() ?? 0,
      repliesCount: (data['repliesCount'] as num?)?.toInt() ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      createdAt: createdAtDate,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'content': content,
    'category': category,
    'authorId': authorId,
    'authorName': authorName,
    'authorRole': authorRole,
    'authorAvatarUrl': authorAvatarUrl,
    'performanceId': performanceId,
    'likesCount': likesCount,
    'repliesCount': repliesCount,
    'likedBy': likedBy,
    'createdAt': FieldValue.serverTimestamp(),
  };

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
  }
}

class CommunityComment {
  final String id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String authorAvatarUrl;
  final String text;
  final DateTime createdAt;
  final int likesCount;
  final List<String> likedBy;

  const CommunityComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    this.authorAvatarUrl = '',
    required this.text,
    required this.createdAt,
    this.likesCount = 0,
    this.likedBy = const [],
  });

  factory CommunityComment.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime createdAtDate = DateTime.now();
    final rawCreated = data['createdAt'];
    if (rawCreated is Timestamp) {
      createdAtDate = rawCreated.toDate();
    } else if (rawCreated is String) {
      createdAtDate = DateTime.tryParse(rawCreated) ?? DateTime.now();
    }
    return CommunityComment(
      id: doc.id,
      authorId: (data['authorId'] ?? '').toString(),
      authorName: (data['authorName'] ?? '').toString(),
      authorRole: (data['authorRole'] ?? '').toString(),
      authorAvatarUrl: (data['authorAvatarUrl'] ?? '').toString(),
      text: (data['text'] ?? '').toString(),
      createdAt: createdAtDate,
      likesCount: (data['likesCount'] as num?)?.toInt() ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
  }
}

class CommunityFirestoreService {
  static final _db = FirebaseFirestore.instance;
  static const _collection = 'community_posts';

  static Future<String> createPost({
    required String title,
    required String content,
    required String category,
    required String authorId,
    required String authorName,
    required String authorRole,
    String authorAvatarUrl = '',
    String performanceId = '',
  }) async {
    final doc = await _db.collection(_collection).add({
      'title': title,
      'content': content,
      'category': category,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'authorAvatarUrl': authorAvatarUrl,
      'performanceId': performanceId,
      'likesCount': 0,
      'repliesCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    appPrint('[Community] Post created: ${doc.id}');
    return doc.id;
  }

  static Stream<List<CommunityPost>> watchAllPosts() {
    return _db
        .collection(_collection)
        .snapshots()
        .asyncMap((snap) async {
          final posts = snap.docs.map(CommunityPost.fromDoc).toList();
          posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final reportedPosts = await SafetyService.getReportedPostIds();
          final blockedUsers = await SafetyService.getBlockedUserIds();
          final restrictedArtists = await SafetyService.getBlockedAndBannedArtistIds();
          final allBlocked = {...blockedUsers, ...restrictedArtists};

          return posts.where((p) {
            if (reportedPosts.contains(p.id)) return false;
            if (allBlocked.contains(p.authorId)) return false;
            return true;
          }).toList();
        });
  }

  static Stream<List<CommunityPost>> watchPostsByAuthor(String authorId) {
    return _db
        .collection(_collection)
        .where('authorId', isEqualTo: authorId)
        .snapshots()
        .asyncMap((snap) async {
          final posts = snap.docs.map(CommunityPost.fromDoc).toList();
          posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final reportedPosts = await SafetyService.getReportedPostIds();
          return posts.where((p) => !reportedPosts.contains(p.id)).toList();
        });
  }

  static Stream<List<CommunityPost>> watchRecentPosts({int limit = 3}) {
    return _db
        .collection(_collection)
        .snapshots()
        .asyncMap((snap) async {
          final posts = snap.docs.map(CommunityPost.fromDoc).toList();
          posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final reportedPosts = await SafetyService.getReportedPostIds();
          final blockedUsers = await SafetyService.getBlockedUserIds();
          final restrictedArtists = await SafetyService.getBlockedAndBannedArtistIds();
          final allBlocked = {...blockedUsers, ...restrictedArtists};

          final filtered = posts.where((p) {
            if (reportedPosts.contains(p.id)) return false;
            if (allBlocked.contains(p.authorId)) return false;
            return true;
          }).toList();

          return filtered.take(limit).toList();
        });
  }

  static Future<void> deletePost(String postId) async {
    await _db.collection(_collection).doc(postId).delete();
    appPrint('[Community] Post deleted: $postId');
  }

  static Future<CommunityPost?> getPost(String postId) async {
    final doc = await _db.collection(_collection).doc(postId).get();
    if (!doc.exists) return null;
    return CommunityPost.fromDoc(doc);
  }

  static Stream<CommunityPost?> watchPost(String postId) {
    return _db
        .collection(_collection)
        .doc(postId)
        .snapshots()
        .map((doc) => doc.exists ? CommunityPost.fromDoc(doc) : null);
  }

  static Future<bool> toggleLike(String postId, String userId) async {
    final docRef = _db.collection(_collection).doc(postId);
    final doc = await docRef.get();
    if (!doc.exists) return false;

    final data = doc.data()!;
    final likedBy = List<String>.from(data['likedBy'] ?? []);
    final isLiked = likedBy.contains(userId);

    if (isLiked) {
      await docRef.update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      await docRef.update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'likesCount': FieldValue.increment(1),
      });
    }

    return !isLiked;
  }

  static Future<bool> toggleCommentLike(String postId, String commentId, String userId) async {
    final docRef = _db
        .collection(_collection)
        .doc(postId)
        .collection('comments')
        .doc(commentId);
    final doc = await docRef.get();
    if (!doc.exists) return false;

    final data = doc.data()!;
    final likedBy = List<String>.from(data['likedBy'] ?? []);
    final isLiked = likedBy.contains(userId);

    if (isLiked) {
      await docRef.update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      await docRef.update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'likesCount': FieldValue.increment(1),
      });
    }

    return !isLiked;
  }

  static Future<void> postComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String authorRole,
    required String text,
    String authorAvatarUrl = '',
  }) async {
    if (ContentFilter.isObjectionable(text)) {
      throw Exception('Your comment contains prohibited or objectionable language.');
    }

    final commentsRef = _db
        .collection(_collection)
        .doc(postId)
        .collection('comments');

    await commentsRef.add({
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'authorAvatarUrl': authorAvatarUrl,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'likesCount': 0,
      'likedBy': [],
    });

    await _db.collection(_collection).doc(postId).update({
      'repliesCount': FieldValue.increment(1),
    });

    appPrint('[Community] Comment posted on $postId');
  }

  static Stream<List<CommunityComment>> watchComments(String postId) {
    return _db
        .collection(_collection)
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snap) async {
          final comments = snap.docs.map(CommunityComment.fromDoc).toList();
          final blockedUsers = await SafetyService.getBlockedUserIds();
          if (blockedUsers.isEmpty) return comments;
          return comments.where((c) => !blockedUsers.contains(c.authorId)).toList();
        });
  }

  static Stream<CommunityPost?> watchPostByPerformanceId(String performanceId) {
    return _db
        .collection(_collection)
        .where('performanceId', isEqualTo: performanceId)
        .where('category', isEqualTo: 'Performance Discussion')
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty ? CommunityPost.fromDoc(snap.docs.first) : null);
  }

  static Future<String> findOrCreatePerformanceDiscussion({
    required String performanceId,
    required String performanceTitle,
    required String authorId,
    required String authorName,
    required String authorRole,
    String authorAvatarUrl = '',
  }) async {
    final existing = await _db
        .collection(_collection)
        .where('performanceId', isEqualTo: performanceId)
        .where('category', isEqualTo: 'Performance Discussion')
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      appPrint('[Community] Found existing discussion for performance: $performanceId');
      return existing.docs.first.id;
    }

    final doc = await _db.collection(_collection).add({
      'title': '$performanceTitle — Discussion',
      'content': 'Join the discussion about this performance!',
      'category': 'Performance Discussion',
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'authorAvatarUrl': authorAvatarUrl,
      'performanceId': performanceId,
      'likesCount': 0,
      'repliesCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    appPrint('[Community] Created discussion for performance: $performanceId (${doc.id})');
    return doc.id;
  }
}
