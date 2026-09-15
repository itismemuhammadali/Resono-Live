import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/modules/artist/community/domain/entities/community_post_entity.dart';
import 'community_discussion_tile.dart';
import 'community_section_title.dart';

class CommunityTrendingSection extends StatelessWidget {
  const CommunityTrendingSection({super.key, required this.posts});

  final List<CommunityPostEntity> posts;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommunitySectionTitle(
          asset: 'assets/icons/png/home_trending_filter_icn.png',
          title: 'Trending Discussions',
        ),
        16.ph,
        ...posts.map(
          (post) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: GestureDetector(
              onTap: () => AppRouterGo.push(
                listenerDiscussionDetailView,
                extra: {
                  'postId': post.id,
                  'authorId': post.authorId,
                  'title': post.title,
                  'tag': post.category,
                  'author': post.authorName,
                  'timeAgo': post.date,
                  'replies': post.comments,
                  'likes': post.likes,
                  'body': post.content,
                  'authorAvatarUrl': post.authorAvatarUrl,
                },
              ),
              child: CommunityDiscussionTile(
                title: post.title,
                tag: post.category,
                author: post.authorName,
                timeAgo: post.date,
                replies: post.comments,
                likes: post.likes,
                authorAvatarUrl: post.authorAvatarUrl,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
