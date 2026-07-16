import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class CommunityDetailPostTile extends StatelessWidget {
  const CommunityDetailPostTile({
    super.key,
    required this.title,
    required this.author,
    required this.timeAgo,
    required this.replies,
    required this.likes,
    required this.pinned,
    this.onTap,
  });

  final String title;
  final String author;
  final String timeAgo;
  final int replies;
  final int likes;
  final bool pinned;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.listenerBackButtonBorder,
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pinned) ...[const _PinnedBadge(), 10.ph],
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryWhite,
            ),
          ),
          8.ph,
          Row(
            children: [
              Text(
                'by $author',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.coolGray,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Text(
                  '·',
                  style: TextStyle(color: AppColors.coolGray, fontSize: 13.sp),
                ),
              ),
              Text(
                timeAgo,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.coolGray,
                ),
              ),
            ],
          ),
          12.ph,
          Row(
            children: [
              Image.asset(
                'assets/icons/png/community_comment_icn.png',
                width: 16.w,
                height: 16.w,
              ),
              6.pw,
              Text(
                '$replies replies',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.coolGray,
                ),
              ),
              20.pw,
              Image.asset(
                'assets/icons/png/community_like_icn.png',
                width: 16.w,
                height: 16.w,
              ),
              6.pw,
              Text(
                '$likes',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.coolGray,
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

class _PinnedBadge extends StatelessWidget {
  const _PinnedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.listenerYellow.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(600.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.push_pin_rounded, size: 12.sp, color: AppColors.eventRed),
          4.pw,
          Text(
            'Pinned',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.listenerYellow,
            ),
          ),
        ],
      ),
    );
  }
}
