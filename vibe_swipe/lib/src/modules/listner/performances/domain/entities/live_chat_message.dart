import 'package:cloud_firestore/cloud_firestore.dart';

enum SuperChatTier {
  bronze,
  silver,
  gold,
  platinum;

  static SuperChatTier get tier1 => bronze;
  static SuperChatTier get tier2 => silver;
  static SuperChatTier get tier3 => gold;
  static SuperChatTier get tier4 => platinum;
}

class LiveChatMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final DateTime createdAt;
  final bool isSuperChat;
  final double donationAmount;
  final String? badge;

  const LiveChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    this.senderAvatar = '',
    required this.createdAt,
    this.isSuperChat = false,
    this.donationAmount = 0.0,
    this.badge,
  });

  SuperChatTier get tier {
    if (badge != null && badge!.isNotEmpty) {
      switch (badge!.toLowerCase()) {
        case 'platinum':
          return SuperChatTier.platinum;
        case 'gold':
          return SuperChatTier.gold;
        case 'silver':
          return SuperChatTier.silver;
        case 'bronze':
        default:
          return SuperChatTier.bronze;
      }
    }
    if (donationAmount >= 25) return SuperChatTier.platinum;
    if (donationAmount >= 10) return SuperChatTier.gold;
    if (donationAmount >= 5) return SuperChatTier.silver;
    return SuperChatTier.bronze;
  }

  int get tierDurationSeconds {
    switch (tier) {
      case SuperChatTier.platinum:
        return 600; // 10 minutes
      case SuperChatTier.gold:
        return 300; // 5 minutes
      case SuperChatTier.silver:
        return 180; // 3 minutes
      case SuperChatTier.bronze:
        return 60; // 1 minute
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
      badge: data['badge'] as String?,
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
    if (badge != null) 'badge': badge,
  };
}
