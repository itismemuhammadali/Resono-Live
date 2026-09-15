import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/modules/artist/community/domain/entities/community_post_entity.dart';
import 'community_section_title.dart';

class CommunityFeaturedSection extends StatelessWidget {
  const CommunityFeaturedSection({super.key, this.post});

  final CommunityPostEntity? post;

  @override
  Widget build(BuildContext context) {
    if (post == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommunitySectionTitle(
          asset: 'assets/icons/png/home_new_filter_icn.png',
          title: 'Featured Discussion',
        ),
        16.ph,
        GestureDetector(
          onTap: () => AppRouterGo.push(
            listenerDiscussionDetailView,
            extra: {
              'postId': post!.id,
              'authorId': post!.authorId,
              'title': post!.title,
              'tag': post!.category,
              'author': post!.authorName,
              'timeAgo': post!.date,
              'replies': post!.comments,
              'likes': post!.likes,
              'body': post!.content,
              'authorAvatarUrl': post!.authorAvatarUrl,
            },
          ),
          child: _FeaturedCard(post: post!),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.post});
  final CommunityPostEntity post;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        height: 190.h,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetworkSnap(
              imageUrl: '',
              width: 1.sw,
              height: 190.h,
              fit: BoxFit.cover,
              radius: 0,
              errorWidget: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1B0040), Color(0xFF0D2040), Color(0xFF001A10)],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.35, 1.0],
                    colors: [
                      Colors.transparent,
                      AppColors.primaryblack.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(top: 12.h, left: 12.w, child: const _TrendingBadge()),
            Align(
              alignment: Alignment.center,
              child: _LabelBadge(label: post.category.isNotEmpty ? post.category : 'Community'),
            ),
            Positioned(
              top: 12.h,
              right: 12.w,
              child: _ViewCountBadge(count: '${post.likes}'),
            ),
            Positioned(
              bottom: 14.h,
              left: 14.w,
              right: 14.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryWhite,
                      shadows: [
                        Shadow(
                          color: AppColors.primaryblack.withValues(alpha: 0.4),
                          offset: Offset(0, 1.h),
                          blurRadius: 4.r,
                        ),
                      ],
                    ),
                  ),
                  8.ph,
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'by ${post.authorName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryWhite.withValues(alpha: 0.74),
                          ),
                        ),
                      ),
                      18.pw,
                      Image.asset(
                        'assets/icons/png/community_comment_icn.png',
                        width: 16.sp,
                        height: 16.sp,
                        color: AppColors.primaryWhite.withValues(alpha: 0.74),
                      ),
                      4.pw,
                      Text(
                        '${post.comments}',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryWhite.withValues(alpha: 0.74),
                        ),
                      ),
                    ],
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

class _TrendingBadge extends StatelessWidget {
  const _TrendingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.listenerYellow,
        borderRadius: BorderRadius.circular(600.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up_rounded, color: AppColors.primaryblack, size: 14.sp),
          8.pw,
          Text(
            'Trending',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryblack,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelBadge extends StatelessWidget {
  const _LabelBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.listenerActiveTab.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(600.r),
        border: Border.all(color: AppColors.listenerActiveTab, width: 1.09.w),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.listenerActiveTab,
        ),
      ),
    );
  }
}

class _ViewCountBadge extends StatelessWidget {
  const _ViewCountBadge({required this.count});
  final String count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.black50,
        borderRadius: BorderRadius.circular(600.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_outline, color: AppColors.primaryWhite, size: 16.sp),
          8.pw,
          Text(
            count,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryWhite,
            ),
          ),
        ],
      ),
    );
  }
}
