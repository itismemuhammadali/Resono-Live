import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class CircularBackButton extends StatelessWidget {
  const CircularBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? AppRouterGo.back,
      child: Container(
        width: 40.w,
        height: 40.w,
        padding: EdgeInsets.symmetric(horizontal: 8.9.w),
        decoration: BoxDecoration(
          color: AppColors.listenerChipBg,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: AppColors.primaryWhite.withValues(alpha: 0.10),
            width: 1.09.w,
          ),
        ),
        child: Icon(
          Icons.chevron_left_rounded,
          color: AppColors.primaryWhite,
          size: 22.sp,
        ),
      ),
    );
  }
}
