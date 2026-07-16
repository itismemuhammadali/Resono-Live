import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/community_activity_entity.dart';

class ArtistCommunityRecentActivitySection extends StatelessWidget {
  const ArtistCommunityRecentActivitySection({
    super.key,
    required this.activities,
  });

  final List<CommunityActivityEntity> activities;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryWhite,
          ),
        ),
        20.5.ph,
        ...activities.map(
          (activity) => Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: _ActivityTile(activity: activity),
          ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final CommunityActivityEntity activity;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: AppColors.listenerActiveTab.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: Image.asset(activity.asset ?? ''),
          ),
          10.pw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${activity.actor} ',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryWhite,
                        ),
                      ),
                      TextSpan(
                        text: activity.action,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primaryWhite,
                        ),
                      ),
                    ],
                  ),
                ),
                4.ph,
                Text(
                  activity.timeAgo,
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
    );
  }
}
