import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibe_swipe/src/modules/listner/performances/domain/entities/live_chat_message.dart';

class LiveChatService {
  static CollectionReference _chatsCollection(String performanceId) =>
      FirebaseFirestore.instance
          .collection('performances')
          .doc(performanceId)
          .collection('chats');

  static Future<void> sendMessage({
    required String performanceId,
    required String text,
    required String senderId,
    required String senderName,
    String senderAvatar = '',
    bool isSuperChat = false,
    double donationAmount = 0.0,
    String? badge,
  }) async {
    await _chatsCollection(performanceId).add({
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'createdAt': FieldValue.serverTimestamp(),
      'isSuperChat': isSuperChat,
      'donationAmount': donationAmount,
      if (badge != null) 'badge': badge,
    });
  }

  static Stream<List<LiveChatMessage>> watchMessages(String performanceId) {
    return _chatsCollection(performanceId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map(LiveChatMessage.fromDoc).toList());
  }

  static Stream<List<LiveChatMessage>> watchMessagesForOverlay(
      String performanceId) {
    return _chatsCollection(performanceId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) {
      final messages = snap.docs.map(LiveChatMessage.fromDoc).toList();
      final superChats = messages.where((m) => m.isSuperChat).toList();
      final regular = messages.where((m) => !m.isSuperChat).toList();
      return [...superChats, ...regular];
    });
  }
}
