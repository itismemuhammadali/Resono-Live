import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class CommunityDiscussionTile extends StatelessWidget {
  const CommunityDiscussionTile({
    super.key,
    required this.title,
    required this.tag,
    required this.author,
    required this.timeAgo,
    required this.replies,
    required this.likes,
    this.authorAvatarUrl = '',
    this.onOptionsTap,
  });

  final String title;
  final String tag;
  final String author;
  final String timeAgo;
  final int replies;
  final int likes;
  final String authorAvatarUrl;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryWhite,
                  ),
                ),
              ),
              10.pw,
              CommunityTagBadge(label: tag, color: AppColors.listenerYellow),
            ],
          ),
          10.ph,
          Row(
            children: [
              if (authorAvatarUrl.isNotEmpty)
                ClipOval(
                  child: NetworkSnap(
                    imageUrl: authorAvatarUrl,
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.cover,
                    borderRadiusGeometry: BorderRadius.circular(10.w),
                  ),
                )
              else
                Icon(
                  Icons.person,
                  size: 14.sp,
                  color: AppColors.coolGray,
                ),
              6.pw,
              Text(
                'by $author',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.coolGray,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Text(
                  '·',
                  style: TextStyle(color: AppColors.coolGray, fontSize: 14.sp),
                ),
              ),
              Text(
                timeAgo,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.coolGray,
                ),
              ),
            ],
          ),
          10.ph,
          Row(
            children: [
              Image.asset('assets/icons/png/community_comment_icn.png'),
              6.pw,
              Text(
                '$replies replies',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.coolGray,
                ),
              ),
              20.pw,
              Image.asset('assets/icons/png/community_like_icn.png'),
              6.pw,
              Text(
                '$likes',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.coolGray,
                ),
              ),
              if (onOptionsTap != null) ...[
                const Spacer(),
                GestureDetector(
                  onTap: onOptionsTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Icon(
                      Icons.more_vert,
                      size: 20.sp,
                      color: AppColors.coolGray,
                    ),
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

class CommunityNewReleaseTile extends StatelessWidget {
  const CommunityNewReleaseTile({
    super.key,
    required this.title,
    required this.author,
    required this.timeAgo,
    required this.replies,
    required this.likes,
    this.authorAvatarUrl = '',
    this.onOptionsTap,
  });

  final String title;
  final String author;
  final String timeAgo;
  final int replies;
  final int likes;
  final String authorAvatarUrl;
  final VoidCallback? onOptionsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.listenerYellow, width: 0.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryWhite,
            ),
          ),
          10.ph,
          Row(
            children: [
              if (authorAvatarUrl.isNotEmpty)
                ClipOval(
                  child: NetworkSnap(
                    imageUrl: authorAvatarUrl,
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.cover,
                    borderRadiusGeometry: BorderRadius.circular(10.w),
                  ),
                )
              else
                Icon(
                  Icons.person,
                  size: 14.sp,
                  color: AppColors.coolGray,
                ),
              6.pw,
              Text(
                'by $author',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.coolGray,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Text(
                  '·',
                  style: TextStyle(color: AppColors.coolGray, fontSize: 14.sp),
                ),
              ),
              Text(
                timeAgo,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.coolGray,
                ),
              ),
            ],
          ),
          10.ph,
          Row(
            children: [
              Image.asset('assets/icons/png/community_comment_icn.png'),
              6.pw,
              Text(
                '$replies replies',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.coolGray,
                ),
              ),
              20.pw,
              Image.asset('assets/icons/png/community_like_icn.png'),
              6.pw,
              Text(
                '$likes',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.coolGray,
                ),
              ),
              if (onOptionsTap != null) ...[
                const Spacer(),
                GestureDetector(
                  onTap: onOptionsTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Icon(
                      Icons.more_vert,
                      size: 20.sp,
                      color: AppColors.coolGray,
                    ),
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

class CommunityTagBadge extends StatelessWidget {
  const CommunityTagBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(600.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
