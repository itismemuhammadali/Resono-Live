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
    this.onShareTap,
    this.onOptionsTap,
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
  final VoidCallback? onShareTap;
  final VoidCallback? onOptionsTap;

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
                width: 40.w,
                height: 40.w,
                borderRadiusGeometry: BorderRadius.circular(20.r),
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF8A2387), Color(0xFFE94057)],
                    ),
                  ),
                  child: Icon(Icons.person, size: 20.sp, color: Colors.white),
                ),
              ),

              12.pw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryWhite,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.coolGray,
                      ),
                    ),
                  ],
                ),
              ),
              CommunityTagBadge(
                label: tag,
                color: AppColors.listenerYellow,
              ),
              if (onOptionsTap != null) ...[
                6.pw,
                GestureDetector(
                  onTap: onOptionsTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Icon(
                      Icons.more_vert,
                      size: 22.sp,
                      color: AppColors.huegrey,
                    ),
                  ),
                ),
              ],
            ],
          ),
          16.ph,
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 22.sp,
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
              height: 1.4,
            ),
          ),
          16.ph,
          Row(
            children: [
              GestureDetector(
                onTap: onLikeTap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isLiked
                        ? AppColors.listenerLiveRed.withValues(alpha: 0.15)
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
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: isLiked ? AppColors.listenerLiveRed : AppColors.primaryWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              12.pw,
              GestureDetector(
                onTap: onShareTap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.listenerBackButtonBorder,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.share_outlined,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      8.pw,
                      Text(
                        'Share',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryWhite,
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
