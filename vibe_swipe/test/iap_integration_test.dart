import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_swipe/src/core/services/in_app_purchase_service.dart';
import 'package:vibe_swipe/src/modules/listner/performances/domain/entities/live_chat_message.dart';

void main() {
  group('In-App Purchase Product Catalog & Tiers Tests', () {
    test('Live Stream Ticket Tiers are correctly defined (6 tiers)', () {
      expect(TicketTier.allTiers.length, 6);

      final tier1 = TicketTier.allTiers[0];
      expect(tier1.tierNumber, 1);
      expect(tier1.price, 2.0);
      expect(tier1.productId, 'com.vibeswipellc.vibeswipe.ticket_tier1');
      expect(tier1.name, 'Tier 1');

      final tier2 = TicketTier.allTiers[1];
      expect(tier2.tierNumber, 2);
      expect(tier2.price, 5.0);
      expect(tier2.productId, 'com.vibeswipellc.vibeswipe.ticket_tier2');

      final tier3 = TicketTier.allTiers[2];
      expect(tier3.tierNumber, 3);
      expect(tier3.price, 10.0);
      expect(tier3.productId, 'com.vibeswipellc.vibeswipe.ticket_tier3');

      final tier4 = TicketTier.allTiers[3];
      expect(tier4.tierNumber, 4);
      expect(tier4.price, 15.0);
      expect(tier4.productId, 'com.vibeswipellc.vibeswipe.ticket_tier4');

      final tier5 = TicketTier.allTiers[4];
      expect(tier5.tierNumber, 5);
      expect(tier5.price, 20.0);
      expect(tier5.productId, 'com.vibeswipellc.vibeswipe.ticket_tier5');

      final tier6 = TicketTier.allTiers[5];
      expect(tier6.tierNumber, 6);
      expect(tier6.price, 25.0);
      expect(tier6.productId, 'com.vibeswipellc.vibeswipe.ticket_tier6');
    });

    test('TicketTier helpers fromPrice and fromTierNumber work accurately', () {
      expect(TicketTier.fromPrice(2.0).tierNumber, 1);
      expect(TicketTier.fromPrice(5.0).tierNumber, 2);
      expect(TicketTier.fromPrice(10.0).tierNumber, 3);
      expect(TicketTier.fromPrice(15.0).tierNumber, 4);
      expect(TicketTier.fromPrice(20.0).tierNumber, 5);
      expect(TicketTier.fromPrice(25.0).tierNumber, 6);

      expect(TicketTier.fromTierNumber(1).price, 2.0);
      expect(TicketTier.fromTierNumber(4).price, 15.0);
      expect(TicketTier.fromTierNumber(6).price, 25.0);
    });

    test('Super Chat Tip Badges are correctly defined (4 Badges: Bronze, Silver, Gold, Platinum)', () {
      expect(SuperChatBadge.allBadges.length, 4);

      final bronze = SuperChatBadge.allBadges[0];
      expect(bronze.id, 'bronze');
      expect(bronze.price, 2.0);
      expect(bronze.pinMinutes, 1);
      expect(bronze.productId, 'com.vibeswipellc.vibeswipe.tip_bronze');

      final silver = SuperChatBadge.allBadges[1];
      expect(silver.id, 'silver');
      expect(silver.price, 5.0);
      expect(silver.pinMinutes, 3);
      expect(silver.productId, 'com.vibeswipellc.vibeswipe.tip_silver');

      final gold = SuperChatBadge.allBadges[2];
      expect(gold.id, 'gold');
      expect(gold.price, 10.0);
      expect(gold.pinMinutes, 5);
      expect(gold.productId, 'com.vibeswipellc.vibeswipe.tip_gold');

      final platinum = SuperChatBadge.allBadges[3];
      expect(platinum.id, 'platinum');
      expect(platinum.price, 25.0);
      expect(platinum.pinMinutes, 10);
      expect(platinum.productId, 'com.vibeswipellc.vibeswipe.tip_platinum');
    });

    test('SuperChatBadge helpers fromId and fromAmount work accurately', () {
      expect(SuperChatBadge.fromId('bronze').price, 2.0);
      expect(SuperChatBadge.fromId('silver').price, 5.0);
      expect(SuperChatBadge.fromId('gold').price, 10.0);
      expect(SuperChatBadge.fromId('platinum').price, 25.0);

      expect(SuperChatBadge.fromAmount(2.0).id, 'bronze');
      expect(SuperChatBadge.fromAmount(5.0).id, 'silver');
      expect(SuperChatBadge.fromAmount(10.0).id, 'gold');
      expect(SuperChatBadge.fromAmount(25.0).id, 'platinum');
    });

    test('LiveChatMessage resolves badge and tier durations correctly', () {
      final msgBronze = LiveChatMessage(
        id: '1',
        text: 'Great stream!',
        senderId: 'u1',
        senderName: 'Fan1',
        createdAt: DateTime.now(),
        isSuperChat: true,
        donationAmount: 2.0,
        badge: 'bronze',
      );
      expect(msgBronze.tier, SuperChatTier.bronze);
      expect(msgBronze.tierDurationSeconds, 60);

      final msgSilver = LiveChatMessage(
        id: '2',
        text: 'Love this track!',
        senderId: 'u2',
        senderName: 'Fan2',
        createdAt: DateTime.now(),
        isSuperChat: true,
        donationAmount: 5.0,
        badge: 'silver',
      );
      expect(msgSilver.tier, SuperChatTier.silver);
      expect(msgSilver.tierDurationSeconds, 180);

      final msgGold = LiveChatMessage(
        id: '3',
        text: 'Awesome artist!',
        senderId: 'u3',
        senderName: 'Fan3',
        createdAt: DateTime.now(),
        isSuperChat: true,
        donationAmount: 10.0,
        badge: 'gold',
      );
      expect(msgGold.tier, SuperChatTier.gold);
      expect(msgGold.tierDurationSeconds, 300);

      final msgPlatinum = LiveChatMessage(
        id: '4',
        text: 'Take all my love!',
        senderId: 'u4',
        senderName: 'Fan4',
        createdAt: DateTime.now(),
        isSuperChat: true,
        donationAmount: 25.0,
        badge: 'platinum',
      );
      expect(msgPlatinum.tier, SuperChatTier.platinum);
      expect(msgPlatinum.tierDurationSeconds, 600);
    });
  });
}
