import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/community_post_entity.dart';

class ArtistCommunityYourPostsSection extends StatelessWidget {
  const ArtistCommunityYourPostsSection({super.key, required this.posts});

  final List<CommunityPostEntity> posts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Posts',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryWhite,
          ),
        ),
        20.5.ph,
        if (posts.isEmpty) _EmptyState() else _PostsList(posts: posts),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryWhite.withValues(alpha: 0.10),
          width: 1.09.w,
        ),
      ),
      child: Column(
        children: [
          Image.asset('assets/icons/png/artist_community_no_post_icn.png'),
          16.ph,
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.huegrey,
            ),
          ),
          20.ph,
          PrimaryElevatedButton(
            onTap: () => AppRouterGo.push(artistCreatePostView),
            text: 'Create Your First Post',
            backgroundColor: AppColors.listenerYellow,
            textColor: Colors.black,
            width: 220.w,
            radius: 16.r,
          ),
        ],
      ),
    );
  }
}

class _PostsList extends StatelessWidget {
  const _PostsList({required this.posts});

  final List<CommunityPostEntity> posts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: posts
          .map(
            (post) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _PostTile(post: post),
            ),
          )
          .toList(),
    );
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post});

  final CommunityPostEntity post;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRouterGo.push(artistPostDetailView, extra: post),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryWhite,
            ),
          ),
          6.ph,
          Text(
            post.subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.huegrey,
            ),
          ),
          12.ph,
          Row(
            children: [
              Image.asset(
                'assets/icons/png/artist_community_post_like_btn_icn.png',
                width: 16.h,
                height: 16.h,
              ),
              6.pw,
              Text(
                '${post.likes}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.huegrey,
                ),
              ),
              20.pw,
              Image.asset(
                'assets/icons/png/community_comment_icn.png',
                width: 16.h,
                height: 16.h,
              ),
              6.pw,
              Text(
                '${post.comments}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.huegrey,
                ),
              ),
              const Spacer(),
              Text(
                post.date,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.huegrey,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
