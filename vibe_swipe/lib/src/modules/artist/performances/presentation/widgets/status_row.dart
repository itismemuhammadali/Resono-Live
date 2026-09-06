import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class StatusRow extends StatelessWidget {
  const StatusRow({super.key, required this.status});

  final PerformanceStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bgColor, textColor) = switch (status) {
      PerformanceStatus.upcoming => (
        'upcoming',
        AppColors.listenerActiveTab.withValues(alpha: 0.20),
        AppColors.listenerActiveTab,
      ),
      PerformanceStatus.past => (
        'past',
        AppColors.listenerPastBadgeBg,
        AppColors.huegrey,
      ),
      PerformanceStatus.live => (
        'live',
        Colors.red.withValues(alpha: 0.20),
        Colors.redAccent,
      ),
      PerformanceStatus.pending => (
        'pending',
        AppColors.listenerPendingBlue.withValues(alpha: 0.20),
        AppColors.listenerPendingBlue,
      ),
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Status',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.huegrey,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
