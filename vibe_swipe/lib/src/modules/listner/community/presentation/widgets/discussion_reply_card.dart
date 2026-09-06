import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class DiscussionReplyCard extends StatelessWidget {
  const DiscussionReplyCard({
    super.key,
    required this.author,
    required this.timeAgo,
    required this.text,
    required this.likes,
    required this.replyCount,
    required this.avatarUrl,
    this.isLiked = false,
    this.onLikeTap,
    this.onMoreTap,
  });

  final String author;
  final String timeAgo;
  final String text;
  final int likes;
  final int replyCount;
  final String avatarUrl;
  final bool isLiked;
  final VoidCallback? onLikeTap;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NetworkSnap(
                imageUrl: avatarUrl,
                width: 40.r,
                height: 40.r,
                fit: BoxFit.cover,
                borderRadiusGeometry: BorderRadius.circular(20.r),
                errorWidget: (_, __, ___) => CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.listenerBackButtonBorder,
                  child: Icon(
                    Icons.person,
                    size: 22.r,
                    color: AppColors.coolGray,
                  ),
                ),
              ),
              12.pw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  author,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryWhite,
                                  ),
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
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.coolGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (onMoreTap != null)
                          GestureDetector(
                            onTap: onMoreTap,
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: EdgeInsets.only(left: 8.w),
                              child: Icon(
                                Icons.more_vert,
                                color: AppColors.huegrey,
                                size: 18.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                    8.ph,
                    Text(
                      text,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.coolGray,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          12.ph,
          Row(
            children: [
              GestureDetector(
                onTap: onLikeTap,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    isLiked ? AppColors.listenerLiveRed : Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/icons/png/discussion_like_icn.png',
                    width: 16.w,
                  ),
                ),
              ),
              6.pw,
              Text(
                '$likes',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isLiked ? AppColors.listenerLiveRed : AppColors.primaryWhite,
                ),
              ),
              if (replyCount > 0) ...[
                18.pw,
                Image.asset(
                  'assets/icons/png/community_comment_icn.png',
                  width: 16.w,
                ),
                6.pw,
                Text(
                  '$replyCount replies',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.coolGray,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
