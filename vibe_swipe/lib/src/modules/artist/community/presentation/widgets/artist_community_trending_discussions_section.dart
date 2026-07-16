import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/community_discussion_entity.dart';

class ArtistCommunityTrendingDiscussionsSection extends StatelessWidget {
  const ArtistCommunityTrendingDiscussionsSection({
    super.key,
    required this.discussions,
  });

  final List<CommunityDiscussionEntity> discussions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trending Discussions',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryWhite,
          ),
        ),
        20.5.ph,
        ...discussions.map(
          (d) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _DiscussionTile(discussion: d),
          ),
        ),
      ],
    );
  }
}

class _DiscussionTile extends StatelessWidget {
  const _DiscussionTile({required this.discussion});

  final CommunityDiscussionEntity discussion;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRouterGo.push(
        artistDiscussionDetailView,
        extra: {
          'id': discussion.id,
          'title': discussion.title,
          'author': discussion.author,
          'authorId': discussion.authorId,
          'likes': discussion.likes,
          'replies': discussion.replies,
          'date': discussion.date,
          'content': discussion.content,
          'replyData': <Map<String, dynamic>>[],
        },
      ),
      child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryWhite.withValues(alpha: 0.10),
          width: 1.09.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: AppColors.listenerYellow.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/icons/png/artist_community_trending_discussions.png',
            ),
          ),
          12.pw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  discussion.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryWhite,
                  ),
                ),
                4.ph,
                Text(
                  '${discussion.author} · ${discussion.replies} replies · ${discussion.date}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.huegrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
