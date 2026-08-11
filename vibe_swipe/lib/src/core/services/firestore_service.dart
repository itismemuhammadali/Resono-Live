import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/app_enums.dart';
import '../utils/app_logger.dart';
import 'python_api_service.dart';

class FirestoreService {
  final PythonApiService _api = PythonApiService();

  int cachedSavedCount = 0;
  int cachedLikedCount = 0;

  Future<void> createUserData({
    required String uid,
    required String name,
    required String email,
    required UserRole role,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': role.name,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      try {
        await _api.post('/users/me', body: {
          'name': name,
          'email': email,
          'role': role.name,
        });
      } catch (apiErr) {
        appPrint('[API] Note: Backend API user creation skipped/failed: $apiErr');
      }
      appPrint('[Firestore] User doc created for $uid (${role.name})');
    } catch (e) {
      appPrint('[Firestore] Error creating user doc: $e');
      rethrow;
    }
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));

      try {
        await _api.put('/users/me', body: data);
      } catch (apiErr) {
        appPrint('[API] Note: Backend API update user skipped/failed: $apiErr');
      }
      appPrint('[Firestore] User doc updated for $uid');
    } catch (e) {
      appPrint('[Firestore] Error updating user doc: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
      final data = await _api.get('/users/me');
      return data;
    } catch (e) {
      appPrint('[Firestore/API] Error getting user data: $e');
      return null;
    }
  }

  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null && doc.data()!['role'] != null) {
        return doc.data()!['role'] as String;
      }
      final data = await _api.get('/users/me/role');
      return data['role'] as String?;
    } catch (e) {
      appPrint('[Firestore/API] Error getting user role: $e');
      return null;
    }
  }

  Future<void> saveArtistProfile({
    required String uid,
    required String artistName,
    required String bio,
    required List<String> genres,
    String? spotifyUrl,
    String? youtubeUrl,
    String? instagramUrl,
    required bool isPublicProfile,
    String? profileImageUrl,
    String? coverUrl,
  }) async {
    try {
      await _api.post('/users/me/artist-profile', body: {
        'artistName': artistName,
        'bio': bio,
        'genres': genres,
        'spotifyUrl': spotifyUrl,
        'youtubeUrl': youtubeUrl,
        'instagramUrl': instagramUrl,
        'isPublicProfile': isPublicProfile,
        'profileImageUrl': profileImageUrl,
        'coverUrl': coverUrl,
      });
      appPrint('[API] Artist profile saved for $uid');
    } catch (e) {
      appPrint('[API] Error saving artist profile: $e');
      rethrow;
    }
  }

  Future<void> saveListenerProfile({
    required String uid,
    required String username,
    required List<String> favoriteGenres,
    required List<String> dislikedGenres,
  }) async {
    try {
      await _api.post('/users/me/listener-profile', body: {
        'username': username,
        'favoriteGenres': favoriteGenres,
        'dislikedGenres': dislikedGenres,
      });
      appPrint('[API] Listener profile saved for $uid');
    } catch (e) {
      appPrint('[API] Error saving listener profile: $e');
      rethrow;
    }
  }

  Future<String> uploadProfileImage(String uid, Uint8List bytes) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('users/$uid/profile.jpg');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final downloadUrl = await ref.getDownloadURL();
      appPrint('[Storage] Profile image uploaded for $uid');
      return downloadUrl;
    } catch (e) {
      appPrint('[Storage] Error uploading profile image: $e');
      rethrow;
    }
  }

  Future<String> uploadBannerImage(String uid, Uint8List bytes) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('users/$uid/banner.jpg');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final downloadUrl = await ref.getDownloadURL();
      appPrint('[Storage] Banner image uploaded for $uid');
      return downloadUrl;
    } catch (e) {
      appPrint('[Storage] Error uploading banner image: $e');
      rethrow;
    }
  }

  Future<String> uploadPerformanceVideo(String performanceId, Uint8List bytes) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('performances/$performanceId/video');
      await ref.putData(bytes, SettableMetadata(contentType: 'video/mp4'));
      final downloadUrl = await ref.getDownloadURL();
      appPrint('[Storage] Performance video uploaded for $performanceId');
      return downloadUrl;
    } catch (e) {
      appPrint('[Storage] Error uploading performance video: $e');
      rethrow;
    }
  }

  Future<String> createPerformance({
    required String artistId,
    required String title,
    String? description,
    List<String>? genres,
    String? status,
    String? type,
    String? thumbnailUrl,
    String? videoUrl,
    DateTime? scheduledAt,
    bool? isPaid,
    double? ticketPrice,
  }) async {
    try {
      final doc = {
        'artist_id': artistId,
        'title': title,
        'description': description ?? '',
        'genres': genres ?? [],
        'status': status ?? 'upcoming',
        'type': type ?? 'live',
        'thumbnailUrl': thumbnailUrl ?? '',
        'videoUrl': videoUrl ?? '',
        'viewers_count': 0,
        'likes_count': 0,
        'saves_count': 0,
        'isPaid': isPaid ?? false,
        'ticketPrice': ticketPrice ?? 0.0,
        'paidUsers': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (scheduledAt != null)
          'scheduledAt': Timestamp.fromDate(scheduledAt),
      };
      final ref = await FirebaseFirestore.instance.collection('performances').add(doc);
      appPrint('[Firestore] Performance created: ${ref.id}');
      return ref.id;
    } catch (e) {
      appPrint('[Firestore] Error creating performance: $e');
      rethrow;
    }
  }

  Future<void> updatePerformance(String performanceId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await FirebaseFirestore.instance.collection('performances').doc(performanceId).update(data);
      appPrint('[Firestore] Performance updated: $performanceId');
    } catch (e) {
      appPrint('[Firestore] Error updating performance: $e');
      rethrow;
    }
  }

  Future<void> startLivePerformance({
    required String performanceId,
    required String channelName,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('performances')
          .doc(performanceId)
          .update({
        'status': 'live',
        'channelName': channelName,
        'current_live_viewers': 0,
        'liveStartedAt': FieldValue.serverTimestamp(),
      });
      appPrint('[Firestore] Live performance started: $performanceId');
    } catch (e) {
      appPrint('[Firestore] Error starting live performance: $e');
      rethrow;
    }
  }

  Future<void> endLivePerformance(String performanceId) async {
    try {
      await FirebaseFirestore.instance
          .collection('performances')
          .doc(performanceId)
          .update({
        'status': 'ended',
        'current_live_viewers': 0,
        'liveEndedAt': FieldValue.serverTimestamp(),
      });
      appPrint('[Firestore] Live performance ended: $performanceId');
    } catch (e) {
      appPrint('[Firestore] Error ending live performance: $e');
      rethrow;
    }
  }

  Stream<DocumentSnapshot> watchPerformance(String performanceId) {
    return FirebaseFirestore.instance
        .collection('performances')
        .doc(performanceId)
        .snapshots();
  }

  Future<String> uploadPerformanceThumbnail(String performanceId, Uint8List bytes) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('performances/$performanceId/thumbnail');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final downloadUrl = await ref.getDownloadURL();
      appPrint('[Storage] Performance thumbnail uploaded for $performanceId');
      return downloadUrl;
    } catch (e) {
      appPrint('[Storage] Error uploading performance thumbnail: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPerformances({
    int limit = 20,
    String? status,
    String? artistId,
  }) async {
    try {
      final data = await _api.get('/performances', queryParams: {
        'limit': limit.toString(),
        if (status != null) 'status': status,
        if (artistId != null) 'artist_id': artistId,
      });
      final list = data['performances'] as List<dynamic>? ?? [];
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      appPrint('[API] Error getting performances: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUserProfileById(String uid) async {
    try {
      final data = await _api.get('/users/$uid');
      return data;
    } catch (e) {
      appPrint('[API] Error getting user profile for $uid: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getArtistStats() async {
    try {
      final data = await _api.get('/artists/me/stats');
      return data;
    } catch (e) {
      appPrint('[API] Error getting artist stats: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getArtistAnalytics() async {
    try {
      final data = await _api.get('/artists/me/analytics');
      return data;
    } catch (e) {
      appPrint('[API] Error getting artist analytics: $e');
      return null;
    }
  }

  Future<void> recordSwipe({required String postId, required bool liked}) async {
    try {
      await _api.post('/posts/$postId/swipe', body: {'liked': liked});
      appPrint('[API] Swipe recorded on $postId: $liked');
    } catch (e) {
      appPrint('[API] Error recording swipe: $e');
    }
  }

  Future<void> likePost({required String postId}) async {
    try {
      final data = await _api.post('/posts/$postId/like');
      appPrint('[API] Like toggled on $postId: $data');
    } catch (e) {
      appPrint('[API] Error liking post: $e');
    }
  }

  Future<void> likePerformance({required String performanceId}) async {
    try {
      await _api.post('/performances/$performanceId/like');
      appPrint('[API] Like toggled on performance $performanceId');
    } catch (e) {
      appPrint('[API] Error liking performance: $e');
    }
  }

  Future<Map<String, dynamic>?> savePerformance({required String performanceId}) async {
    try {
      final data = await _api.post('/performances/$performanceId/save');
      appPrint('[API] Save toggled on performance $performanceId');
      if (data != null && data['savedCount'] is num) {
        cachedSavedCount = (data['savedCount'] as num).toInt();
      }
      return data;
    } catch (e) {
      appPrint('[API] Error saving performance: $e');
      return null;
    }
  }

  Future<void> recordPerformanceView({required String performanceId}) async {
    try {
      await _api.post('/performances/$performanceId/view');
      appPrint('[API] View recorded for performance $performanceId');
    } catch (e) {
      appPrint('[API] Error recording view: $e');
    }
  }

  Future<void> joinPerformance({required String performanceId}) async {
    // Always update Firestore directly for accurate real-time viewer count.
    // current_live_viewers tracks active live listeners (goes up/down)
    // viewers_count tracks cumulative total views (only goes up)
    try {
      await FirebaseFirestore.instance.collection('performances').doc(performanceId).update({
        'current_live_viewers': FieldValue.increment(1),
        'viewers_count': FieldValue.increment(1),
      });
    } catch (_) {}
    try {
      await _api.post('/performances/$performanceId/join');
      appPrint('[API] Joined performance $performanceId');
    } catch (e) {
      appPrint('[API] Error joining performance: $e');
    }
  }

  Future<void> leavePerformance({required String performanceId}) async {
    // Decrement active live viewers count when leaving (do NOT reduce total viewers_count)
    try {
      await FirebaseFirestore.instance.collection('performances').doc(performanceId).update({
        'current_live_viewers': FieldValue.increment(-1),
      });
    } catch (_) {}
    try {
      await _api.post('/performances/$performanceId/leave');
      appPrint('[API] Left performance $performanceId');
    } catch (e) {
      appPrint('[API] Error leaving performance: $e');
    }
  }


  Future<Map<String, dynamic>?> getPerformanceLikeSaveState({required String performanceId}) async {
    try {
      final data = await _api.get('/performances/$performanceId/state');
      return data;
    } catch (e) {
      appPrint('[API] Error getting performance state: $e');
      return null;
    }
  }

  Future<void> recordPlay({required String postId}) async {
    try {
      await _api.post('/artists/me/posts/$postId/play');
      appPrint('[API] Play recorded for $postId');
    } catch (e) {
      appPrint('[API] Error recording play: $e');
    }
  }

  Future<Map<String, dynamic>?> toggleFollow({required String artistId}) async {
    try {
      final data = await _api.post('/users/$artistId/follow');
      appPrint('[API] Follow toggled on $artistId: $data');
      return data;
    } catch (e) {
      appPrint('[API] Error toggling follow: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getFollowState({required String artistId}) async {
    try {
      final data = await _api.get('/users/$artistId/follow-state');
      return data;
    } catch (e) {
      appPrint('[API] Error getting follow state: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLibraryStats() async {
    try {
      final data = await _api.get('/users/me/library-stats');
      if (data != null) {
        if (data['savedCount'] is num) {
          cachedSavedCount = (data['savedCount'] as num).toInt();
        }
        if (data['likedCount'] is num) {
          cachedLikedCount = (data['likedCount'] as num).toInt();
        }
      }
      return data;
    } catch (e) {
      appPrint('[API] Error getting library stats: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getSavedSongs() async {
    try {
      final data = await _api.get('/users/me/saved-songs');
      if (data != null && data['songs'] is List) {
        return List<Map<String, dynamic>>.from(data['songs']);
      }
      return [];
    } catch (e) {
      appPrint('[API] Error getting saved songs: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getListeningHistory() async {
    try {
      final data = await _api.get('/users/me/history');
      if (data != null && data['history'] is List) {
        return List<Map<String, dynamic>>.from(data['history']);
      }
      return [];
    } catch (e) {
      appPrint('[API] Error getting listening history: $e');
      return [];
    }
  }

  // ── Search ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> searchUsers({
    String? q,
    String? genre,
    int limit = 20,
  }) async {
    try {
      final data = await _api.get('/search/users', queryParams: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (genre != null) 'genre': genre,
        'limit': limit.toString(),
      });
      final list = data['users'] as List<dynamic>? ?? [];
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      appPrint('[API] Error searching users: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTrendingGenres({int limit = 10}) async {
    try {
      final data = await _api.get('/search/trending-genres', queryParams: {
        'limit': limit.toString(),
      });
      final list = data['genres'] as List<dynamic>? ?? [];
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      appPrint('[API] Error getting trending genres: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTrendingArtists({int limit = 10}) async {
    try {
      final data = await _api.get('/search/trending-artists', queryParams: {
        'limit': limit.toString(),
      });
      final list = data['artists'] as List<dynamic>? ?? [];
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      appPrint('[API] Error getting trending artists: $e');
      return [];
    }
  }
}
