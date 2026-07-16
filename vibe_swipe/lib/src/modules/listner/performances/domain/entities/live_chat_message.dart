import 'package:cloud_firestore/cloud_firestore.dart';

enum SuperChatTier { tier1, tier2, tier3 }

class LiveChatMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final DateTime createdAt;
  final bool isSuperChat;
  final double donationAmount;

  const LiveChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    this.senderAvatar = '',
    required this.createdAt,
    this.isSuperChat = false,
    this.donationAmount = 0.0,
  });

  SuperChatTier get tier {
    if (donationAmount >= 25) return SuperChatTier.tier3;
    if (donationAmount >= 10) return SuperChatTier.tier2;
    return SuperChatTier.tier1;
  }

  int get tierDurationSeconds {
    switch (tier) {
      case SuperChatTier.tier3:
        return 120;
      case SuperChatTier.tier2:
        return 60;
      case SuperChatTier.tier1:
        return 30;
    }
  }

  factory LiveChatMessage.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LiveChatMessage(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderAvatar: data['senderAvatar'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isSuperChat: data['isSuperChat'] ?? false,
      donationAmount: (data['donationAmount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'text': text,
    'senderId': senderId,
    'senderName': senderName,
    'senderAvatar': senderAvatar,
    'createdAt': FieldValue.serverTimestamp(),
    'isSuperChat': isSuperChat,
    'donationAmount': donationAmount,
  };
}
