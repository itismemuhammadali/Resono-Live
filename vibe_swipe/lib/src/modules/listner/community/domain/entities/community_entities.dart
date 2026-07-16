import 'package:vibe_swipe/src/modules/artist/community/domain/entities/community_post_entity.dart';

class TrendingDiscussion {
  final String title;
  final String author;
  final int replies;
  final String date;
  final String body;
  final String authorAvatar;

  const TrendingDiscussion({
    required this.title,
    required this.author,
    required this.replies,
    required this.date,
    required this.body,
    this.authorAvatar = '',
  });

  factory TrendingDiscussion.fromPost(CommunityPostEntity post) {
    return TrendingDiscussion(
      title: post.title,
      author: post.authorName,
      replies: post.comments,
      date: post.date,
      body: post.content,
    );
  }
}

class GenreCommunity {
  final String name;
  final int memberCount;
  final int postCount;

  const GenreCommunity({
    required this.name,
    required this.memberCount,
    required this.postCount,
  });
}

class CommunityActivityItem {
  final String actor;
  final String action;
  final String timeAgo;

  const CommunityActivityItem({
    required this.actor,
    required this.action,
    required this.timeAgo,
  });
}

class CommunityDerivedData {
  static List<TrendingDiscussion> trendingDiscussions(List<CommunityPostEntity> posts) {
    return posts
        .where((p) => p.content.isNotEmpty)
        .take(5)
        .map(TrendingDiscussion.fromPost)
        .toList();
  }

  static List<GenreCommunity> genreCommunities(List<CommunityPostEntity> posts) {
    final Map<String, int> categoryCounts = {};
    for (final post in posts) {
      if (post.category.isNotEmpty) {
        categoryCounts[post.category] = (categoryCounts[post.category] ?? 0) + 1;
      }
    }
    return categoryCounts.entries
        .map((e) => GenreCommunity(
              name: e.key,
              memberCount: e.value,
              postCount: e.value,
            ))
        .toList();
  }

  static List<CommunityPostEntity> newReleases(List<CommunityPostEntity> posts) {
    return posts
        .where((p) => p.category.toLowerCase().contains('new release'))
        .toList();
  }

  static List<CommunityActivityItem> recentActivity(List<CommunityPostEntity> posts) {
    return posts.take(4).map((p) {
      return CommunityActivityItem(
        actor: p.authorName,
        action: 'posted "${p.title}"',
        timeAgo: p.date,
      );
    }).toList();
  }
}
