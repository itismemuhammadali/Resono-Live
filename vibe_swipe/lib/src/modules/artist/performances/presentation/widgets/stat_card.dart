import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border(
          top: BorderSide(
            color: AppColors.primaryWhite.withValues(alpha: 0.10),
            width: 1.09,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.listenerActiveTab, size: 24.sp),
          6.ph,
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryWhite,
            ),
          ),
          6.ph,
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.huegrey,
            ),
          ),
        ],
      ),
    );
  }
}
