import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/core/utils/report_block_helper.dart';
import '../../domain/entities/community_post_entity.dart';

class ArtistPostDetailPostCard extends StatelessWidget {
  const ArtistPostDetailPostCard({super.key, required this.post});

  final CommunityPostEntity post;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryWhite,
            ),
          ),
          6.ph,
          Text(
            post.subtitle,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.huegrey,
            ),
          ),
          16.ph,
          Row(
            children: [
              Image.asset(
                'assets/icons/png/artist_community_post_like_btn_icn.png',
                width: 16.h,
                height: 16.h,
                color: AppColors.primaryWhite,
              ),
              6.pw,
              Text(
                '${post.likes}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryWhite,
                ),
              ),
              20.pw,
              Image.asset(
                'assets/icons/png/community_comment_icn.png',
                width: 16.h,
                height: 16.h,
                color: AppColors.primaryWhite,
              ),
              6.pw,
              Text(
                '${post.comments} comments',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryWhite,
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
              8.pw,
              GestureDetector(
                onTap: () {
                  ReportBlockHelper.showPostOptionsModal(
                    context,
                    authorName: post.authorName.isNotEmpty ? post.authorName : 'User',
                    postId: post.id,
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Icon(
                    Icons.more_vert,
                    size: 18.sp,
                    color: AppColors.huegrey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
