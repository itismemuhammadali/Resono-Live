import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class UpcomingPerformanceStatsRow extends StatelessWidget {
  const UpcomingPerformanceStatsRow({super.key, required this.views});

  final int views;

  String _formatViews(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.visibility_outlined,
          color: AppColors.primaryWhite.withValues(alpha: 0.55),
          size: 15.sp,
        ),
        6.pw,
        Text(
          '${_formatViews(views)} views',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryWhite.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
