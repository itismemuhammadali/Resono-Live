import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SafetyService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // In-memory cache for restricted artist IDs with 60-second TTL
  static Set<String>? _cachedRestrictedArtistIds;
  static DateTime? _cacheTimestamp;

  // In-memory cache for blocked user IDs
  static Set<String>? _cachedBlockedUserIds;
  static DateTime? _blockedCacheTimestamp;

  static String? get _currentUserId => _auth.currentUser?.uid;

  static void invalidateCache() {
    _cachedRestrictedArtistIds = null;
    _cacheTimestamp = null;
    _cachedBlockedUserIds = null;
    _blockedCacheTimestamp = null;
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

    try {
      final batch = _db.batch();

      // Store in user's blocked subcollection
      final userBlockRef = _db.collection('users').doc(uid).collection('blocked_users').doc(targetUserId);
      batch.set(userBlockRef, {
        'blockedUserId': targetUserId,
        'blockedUserName': targetUserName,
        'createdAt': FieldValue.serverTimestamp(),
        'permanent': true,
      });

      // Store in root blocks collection for bidirectional lookup
      final rootBlockRef = _db.collection('blocks').doc('${uid}_$targetUserId');
      batch.set(rootBlockRef, {
        'blockerId': uid,
        'blockedId': targetUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Auto-notify developer of inappropriate/abusive user report
      final reportRef = _db.collection('reports').doc();
      batch.set(reportRef, {
        'reporterId': uid,
        'reportedUserId': targetUserId,
        'reportedUserName': targetUserName,
        'targetType': 'blocked_user',
        'targetId': targetUserId,
        'reason': 'User permanently blocked (Auto-reported to developer for moderation review)',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      await batch.commit();
      invalidateCache();
      debugPrint('[SafetyService] User $targetUserId permanently blocked by $uid & reported to developer');
    } catch (e) {
      debugPrint('[SafetyService] Error blocking user: $e');
      rethrow;
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
  }) async {
    final uid = _currentUserId;
    if (uid == null) return;

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
      final userBlockedSnap = await _db
          .collection('users')
          .doc(uid)
          .collection('blocked_users')
          .get();
      for (final doc in userBlockedSnap.docs) {
        restricted.add(doc.id);
      }

      // 2. Artists who blocked current user
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

      // 3. Active 7-day shadow bans on current user
      final nowTimestamp = Timestamp.now();
      final shadowBanSnap = await _db
          .collection('shadow_bans')
          .where('userId', isEqualTo: uid)
          .where('bannedUntil', isGreaterThan: nowTimestamp)
          .get();
      for (final doc in shadowBanSnap.docs) {
        final artistId = doc.data()['artistId'] as String?;
        if (artistId != null && artistId.isNotEmpty) {
          restricted.add(artistId);
        }
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
    if (uid == null) return <String>{};

    final now = DateTime.now();
    if (_cachedBlockedUserIds != null &&
        _blockedCacheTimestamp != null &&
        now.difference(_blockedCacheTimestamp!) < const Duration(seconds: 60)) {
      return _cachedBlockedUserIds!;
    }

    final Set<String> blocked = {};

    try {
      final userBlockedSnap = await _db
          .collection('users')
          .doc(uid)
          .collection('blocked_users')
          .get();
      for (final doc in userBlockedSnap.docs) {
        blocked.add(doc.id);
      }

      _cachedBlockedUserIds = blocked;
      _blockedCacheTimestamp = DateTime.now();
    } catch (e) {
      debugPrint('[SafetyService] Error getting blocked user IDs: $e');
    }

    return blocked;
  }
}
