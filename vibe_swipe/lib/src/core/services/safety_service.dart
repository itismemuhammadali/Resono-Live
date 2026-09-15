import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:vibe_swipe/src/core/services/local_db_service/secure_storage.dart';
import 'package:vibe_swipe/src/core/services/registry_service/di.dart';

class SafetyService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Broadcast notifier so UI components instantly re-filter posts/comments when a block or report happens
  static final ValueNotifier<int> safetyNotifier = ValueNotifier<int>(0);
  static void notifySafetyChanged() => safetyNotifier.value++;

  // In-memory cache for restricted artist IDs with 60-second TTL
  static Set<String>? _cachedRestrictedArtistIds;
  static DateTime? _cacheTimestamp;

  // In-memory cache for blocked user IDs
  static Set<String>? _cachedBlockedUserIds;
  static DateTime? _blockedCacheTimestamp;

  // In-memory cache for reported post IDs
  static Set<String>? _cachedReportedPostIds;
  static DateTime? _reportedCacheTimestamp;

  static String? get currentUserId => _auth.currentUser?.uid;
  static String? get _currentUserId => currentUserId;

  static Set<String> get cachedReportedPostIds => _cachedReportedPostIds ?? {};
  static Set<String> get cachedBlockedUserIds => _cachedBlockedUserIds ?? {};

  static void invalidateCache() {
    _cachedRestrictedArtistIds = null;
    _cacheTimestamp = null;
    _cachedBlockedUserIds = null;
    _blockedCacheTimestamp = null;
    _cachedReportedPostIds = null;
    _reportedCacheTimestamp = null;
    notifySafetyChanged();
  }

  /// Reports a comment and registers a 7-day shadow-ban against the commenter for this artist
  static Future<void> reportCommentAndShadowBan({
    required String reportedUserId,
    required String reportedUserName,
    required String commentId,
    required String commentText,
    required String reason,
    String? artistId,
  }) async {
    final uid = _currentUserId;
    if (uid == null) return;

    final effectiveArtistId = artistId ?? uid;

    try {
      final batch = _db.batch();

      // 1. Add report to 'reports' collection
      final reportRef = _db.collection('reports').doc();
      batch.set(reportRef, {
        'reporterId': uid,
        'reportedUserId': reportedUserId,
        'reportedUserName': reportedUserName,
        'targetType': 'comment',
        'targetId': commentId,
        'commentText': commentText,
        'reason': reason,
        'artistId': effectiveArtistId,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      // 2. Add 7-day shadow-ban in 'shadow_bans' collection
      final banUntil = DateTime.now().add(const Duration(days: 7));
      final banRef = _db.collection('shadow_bans').doc('${effectiveArtistId}_$reportedUserId');
      batch.set(banRef, {
        'artistId': effectiveArtistId,
        'userId': reportedUserId,
        'userName': reportedUserName,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
        'bannedUntil': Timestamp.fromDate(banUntil),
      });

      await batch.commit();
      invalidateCache();
      debugPrint('[SafetyService] Report filed & 7-day shadow ban applied for $reportedUserId by $effectiveArtistId');
    } catch (e) {
      debugPrint('[SafetyService] Error reporting comment & applying shadow ban: $e');
      rethrow;
    }
  }

  /// Permanently blocks a user
  static Future<void> blockUser({
    required String targetUserId,
    required String targetUserName,
  }) async {
    final uid = _currentUserId;
    if (uid == null) return;

    final cleanTargetUserId = targetUserId.trim();
    if (cleanTargetUserId.isEmpty) {
      debugPrint('[SafetyService] Cannot block user: targetUserId is empty');
      throw ArgumentError('Cannot block user: User ID is missing or invalid.');
    }
    if (cleanTargetUserId == uid) {
      debugPrint('[SafetyService] Cannot block self');
      return;
    }

    // 1. Immediately cache in memory so UI reflects it synchronously
    _cachedBlockedUserIds ??= <String>{};
    _cachedBlockedUserIds!.add(cleanTargetUserId);
    _blockedCacheTimestamp = DateTime.now();

    // 2. Persist locally to secure storage so it stays blocked across sessions
    try {
      final prefs = locator<Prefs>();
      final localList = await prefs.readList('blocked_user_ids') ?? [];
      if (!localList.contains(cleanTargetUserId)) {
        localList.add(cleanTargetUserId);
        await prefs.storeList('blocked_user_ids', localList);
      }
    } catch (e) {
      debugPrint('[SafetyService] Local storage save error for block: $e');
    }

    // 3. Immediately notify UI listeners
    notifySafetyChanged();

    try {
      final batch = _db.batch();

      // Store in user's blocked subcollection
      final userBlockRef = _db.collection('users').doc(uid).collection('blocked_users').doc(cleanTargetUserId);
      batch.set(userBlockRef, {
        'blockedUserId': cleanTargetUserId,
        'blockedUserName': targetUserName,
        'createdAt': FieldValue.serverTimestamp(),
        'permanent': true,
      });

      // Store in root blocks collection for bidirectional lookup
      final rootBlockRef = _db.collection('blocks').doc('${uid}_$cleanTargetUserId');
      batch.set(rootBlockRef, {
        'blockerId': uid,
        'blockedId': cleanTargetUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Auto-notify developer of inappropriate/abusive user report
      final reportRef = _db.collection('reports').doc();
      batch.set(reportRef, {
        'reporterId': uid,
        'reportedUserId': cleanTargetUserId,
        'reportedUserName': targetUserName,
        'targetType': 'blocked_user',
        'targetId': cleanTargetUserId,
        'reason': 'User permanently blocked (Auto-reported to developer for moderation review)',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      await batch.commit();
      invalidateCache();
      debugPrint('[SafetyService] User $cleanTargetUserId permanently blocked by $uid & reported to developer');
    } catch (e) {
      debugPrint('[SafetyService] Error blocking user in Firestore (local block still active): $e');
    }
  }

  /// Reports an artist
  static Future<void> reportArtist({
    required String artistId,
    required String artistName,
    required String reason,
  }) async {
    final uid = _currentUserId;
    if (uid == null) return;

    try {
      await _db.collection('reports').add({
        'reporterId': uid,
        'reportedUserId': artistId,
        'reportedUserName': artistName,
        'targetType': 'artist',
        'targetId': artistId,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      debugPrint('[SafetyService] Artist $artistId reported by $uid');
    } catch (e) {
      debugPrint('[SafetyService] Error reporting artist: $e');
      rethrow;
    }
  }

  /// Reports generic content (performance, song, post)
  static Future<void> reportContent({
    required String contentType,
    required String contentId,
    required String reason,
    String? authorId,
    String? authorName,
  }) async {
    final uid = _currentUserId;
    if (uid == null) return;

    if (contentType.toLowerCase() == 'post') {
      await reportPost(
        postId: contentId,
        reason: reason,
        authorId: authorId,
        authorName: authorName,
      );
      return;
    }

    try {
      await _db.collection('reports').add({
        'reporterId': uid,
        'targetType': contentType.toLowerCase(),
        'targetId': contentId,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      debugPrint('[SafetyService] Content $contentId ($contentType) reported by $uid');
    } catch (e) {
      debugPrint('[SafetyService] Error reporting content: $e');
    }
  }

  /// Reports a community post and hides it immediately for this user
  static Future<void> reportPost({
    required String postId,
    required String reason,
    String? authorId,
    String? authorName,
  }) async {
    final uid = _currentUserId;
    if (uid == null) return;
    final cleanPostId = postId.trim();
    if (cleanPostId.isEmpty) return;

    // 1. Immediately cache in memory so UI reflects it synchronously
    _cachedReportedPostIds ??= <String>{};
    _cachedReportedPostIds!.add(cleanPostId);
    _reportedCacheTimestamp = DateTime.now();

    // 2. Persist locally to secure storage so it stays hidden across sessions
    try {
      final prefs = locator<Prefs>();
      final localList = await prefs.readList('reported_post_ids') ?? [];
      if (!localList.contains(cleanPostId)) {
        localList.add(cleanPostId);
        await prefs.storeList('reported_post_ids', localList);
      }
    } catch (e) {
      debugPrint('[SafetyService] Local storage save error: $e');
    }

    // 3. Immediately notify UI listeners
    notifySafetyChanged();

    // 4. Save report in 'reports' collection for moderation
    try {
      await _db.collection('reports').add({
        'reporterId': uid,
        'reportedUserId': authorId ?? '',
        'reportedUserName': authorName ?? '',
        'targetType': 'post',
        'targetId': cleanPostId,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      debugPrint('[SafetyService] Error adding to reports collection: $e');
    }

    // 5. Try saving in user's reported_posts subcollection (non-blocking if rules not yet updated)
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('reported_posts')
          .doc(cleanPostId)
          .set({
        'postId': cleanPostId,
        'reportedAt': FieldValue.serverTimestamp(),
        'reason': reason,
      });
    } catch (e) {
      debugPrint('[SafetyService] Note: user reported_posts write error (handled gracefully): $e');
    }

    debugPrint('[SafetyService] Post $cleanPostId reported and hidden for user $uid');
  }

  /// Returns post IDs reported by current user so they are hidden from feeds
  static Future<Set<String>> getReportedPostIds() async {
    final uid = _currentUserId;
    if (uid == null) return _cachedReportedPostIds ?? <String>{};

    final now = DateTime.now();
    if (_cachedReportedPostIds != null &&
        _reportedCacheTimestamp != null &&
        now.difference(_reportedCacheTimestamp!) < const Duration(seconds: 60)) {
      return _cachedReportedPostIds!;
    }

    final Set<String> reported = {};

    // 1. Read from local storage first (always fast and reliable)
    try {
      final localList = await locator<Prefs>().readList('reported_post_ids');
      if (localList != null) {
        reported.addAll(localList.where((id) => id.trim().isNotEmpty));
      }
    } catch (_) {}

    // 2. Read from Firestore if available
    try {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('reported_posts')
          .get();
      for (final doc in snap.docs) {
        reported.add(doc.id);
      }
    } catch (e) {
      debugPrint('[SafetyService] Error getting reported post IDs from Firestore: $e');
    }

    _cachedReportedPostIds = reported;
    _reportedCacheTimestamp = DateTime.now();
    return reported;
  }

  /// Returns artist IDs whose performances and posts the current user must NOT see
  /// (covers both permanent blocks and active 7-day shadow-bans)
  static Future<Set<String>> getBlockedAndBannedArtistIds() async {
    final uid = _currentUserId;
    if (uid == null) return <String>{};

    final now = DateTime.now();
    if (_cachedRestrictedArtistIds != null &&
        _cacheTimestamp != null &&
        now.difference(_cacheTimestamp!) < const Duration(seconds: 60)) {
      return _cachedRestrictedArtistIds!;
    }

    final Set<String> restricted = {};

    try {
      // 1. Artists blocked by current user
      final userBlocked = await getBlockedUserIds();
      restricted.addAll(userBlocked);

      // 2. Artists who blocked current user
      try {
        final blockedBySnap = await _db
            .collection('blocks')
            .where('blockedId', isEqualTo: uid)
            .get();
        for (final doc in blockedBySnap.docs) {
          final blockerId = doc.data()['blockerId'] as String?;
          if (blockerId != null && blockerId.isNotEmpty) {
            restricted.add(blockerId);
          }
        }
      } catch (e) {
        debugPrint('[SafetyService] Error querying blocks collection: $e');
      }

      // 3. Active 7-day shadow bans on current user (filter in-memory to avoid composite index error)
      try {
        final nowTimestamp = Timestamp.now();
        final shadowBanSnap = await _db
            .collection('shadow_bans')
            .where('userId', isEqualTo: uid)
            .get();
        for (final doc in shadowBanSnap.docs) {
          final data = doc.data();
          final bannedUntil = data['bannedUntil'];
          if (bannedUntil is Timestamp && bannedUntil.compareTo(nowTimestamp) > 0) {
            final artistId = data['artistId'] as String?;
            if (artistId != null && artistId.isNotEmpty) {
              restricted.add(artistId);
            }
          }
        }
      } catch (e) {
        debugPrint('[SafetyService] Error querying shadow_bans: $e');
      }

      _cachedRestrictedArtistIds = restricted;
      _cacheTimestamp = DateTime.now();
    } catch (e) {
      debugPrint('[SafetyService] Error getting restricted artist IDs: $e');
    }

    return restricted;
  }

  /// Returns user IDs blocked by current user (for filtering comments/chat)
  static Future<Set<String>> getBlockedUserIds() async {
    final uid = _currentUserId;
    if (uid == null) return _cachedBlockedUserIds ?? <String>{};

    final now = DateTime.now();
    if (_cachedBlockedUserIds != null &&
        _blockedCacheTimestamp != null &&
        now.difference(_blockedCacheTimestamp!) < const Duration(seconds: 60)) {
      return _cachedBlockedUserIds!;
    }

    final Set<String> blocked = {};

    // 1. Read from local storage first
    try {
      final localList = await locator<Prefs>().readList('blocked_user_ids');
      if (localList != null) {
        blocked.addAll(localList.where((id) => id.trim().isNotEmpty));
      }
    } catch (_) {}

    // 2. Read from Firestore
    try {
      final userBlockedSnap = await _db
          .collection('users')
          .doc(uid)
          .collection('blocked_users')
          .get();
      for (final doc in userBlockedSnap.docs) {
        blocked.add(doc.id);
      }
    } catch (e) {
      debugPrint('[SafetyService] Error getting blocked user IDs from Firestore: $e');
    }

    _cachedBlockedUserIds = blocked;
    _blockedCacheTimestamp = DateTime.now();
    return blocked;
  }
}
