import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'community_discussion_tile.dart' show CommunityTagBadge;

class DiscussionOriginalPost extends StatelessWidget {
  const DiscussionOriginalPost({
    super.key,
    required this.title,
    required this.author,
    required this.timeAgo,
    required this.tag,
    required this.replies,
    required this.likes,
    required this.body,
    this.authorAvatarUrl,
    this.isLiked = false,
    this.onLikeTap,
  });

  final String title;
  final String author;
  final String timeAgo;
  final String tag;
  final int replies;
  final int likes;
  final String body;
  final String? authorAvatarUrl;
  final bool isLiked;
  final VoidCallback? onLikeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              NetworkSnap(
                imageUrl: authorAvatarUrl,
                width: 48.r,
                height: 48.r,
                fit: BoxFit.cover,
                borderRadiusGeometry: BorderRadius.circular(24.r),
                errorWidget: (_, __, ___) => CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppColors.listenerBackButtonBorder,
                  child: Icon(
                    Icons.person,
                    size: 22.r,
                    color: AppColors.coolGray,
                  ),
                ),
              ),
              10.pw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          author,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryWhite,
                          ),
                        ),
                        6.pw,
                        Text(
                          '·',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.coolGray,
                          ),
                        ),
                        6.pw,
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 12.sp,
                            color: AppColors.coolGray,
                          ),
                        ),
                      ],
                    ),
                    6.ph,
                    CommunityTagBadge(
                      label: tag,
                      color: AppColors.listenerYellow,
                    ),
                  ],
                ),
              ),
            ],
          ),
          14.ph,
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryWhite,
            ),
          ),
          10.ph,
          Text(
            body,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.coolGray,
              height: 1.5,
            ),
          ),
          14.ph,
          Divider(color: AppColors.listenerBackButtonBorder, thickness: 1),
          10.ph,
          Row(
            children: [
              GestureDetector(
                onTap: onLikeTap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isLiked
                        ? AppColors.listenerLiveRed.withValues(alpha: 0.2)
                        : AppColors.listenerBackButtonBorder,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          isLiked ? AppColors.listenerLiveRed : Colors.white,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset('assets/icons/png/discussion_like_icn.png'),
                      ),
                      10.pw,
                      Text(
                        '$likes',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                          color: isLiked ? AppColors.listenerLiveRed : AppColors.primaryWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              20.pw,
              Image.asset('assets/icons/png/community_comment_icn.png'),
              6.pw,
              Text(
                '$replies replies',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.coolGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
