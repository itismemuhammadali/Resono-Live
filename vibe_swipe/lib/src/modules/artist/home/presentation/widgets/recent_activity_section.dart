import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/activity_entity.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key, required this.activities});

  final List<ActivityEntity> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) return const SizedBox.shrink();

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
        12.ph,
        ...activities.map(
          (activity) => Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: _ActivityRow(activity: activity),
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final ActivityEntity activity;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: activity.iconBgColor.withValues(alpha: 0.20),
            shape: BoxShape.circle,
          ),
          child: activity.asset != null
              ? Image.asset(
                  activity.asset!,
                  width: 14.w,
                  height: 14.w,
                  color: activity.iconBgColor,
                )
              : Icon(activity.icon, color: activity.iconBgColor, size: 14.w),
        ),
        12.pw,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.description,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryWhite,
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
    );
  }
}
