import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class PerformancesEmptyState extends StatelessWidget {
  const PerformancesEmptyState({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: AppColors.listenerChipBg,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Image.asset(
              AppAssetsPng.performanceUnselectedIcn,
              width: 36.w,
              height: 36.w,
              color: AppColors.huegrey,
            ),
          ),
          16.ph,
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.huegrey,
            ),
          ),
        ],
      ),
    );
  }
}
