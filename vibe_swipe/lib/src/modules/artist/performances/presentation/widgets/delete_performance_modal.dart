import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class DeletePerformanceModal extends StatelessWidget {
  const DeletePerformanceModal({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  static Future<void> show(BuildContext context, VoidCallback onConfirm) {
    return showDialog(
      context: context,
      barrierColor: AppColors.primaryblack.withValues(alpha: 0.7),
      builder: (_) => DeletePerformanceModal(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.listenerDashboardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: AppColors.artistEndSessionRed.withValues(
                      alpha: 0.15,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.artistEndSessionRed,
                    size: 24.sp,
                  ),
                ),
                GestureDetector(
                  onTap: () => AppRouterGo.back(),
                  child: Icon(
                    Icons.close,
                    color: AppColors.primaryWhite,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
            20.ph,
            Text(
              'Delete Performance',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryWhite,
              ),
            ),
            10.ph,
            Text(
              'Are you sure you want to delete this performance? This action cannot be undone.',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.huegrey,
                height: 1.5,
              ),
            ),
            24.ph,
            Row(
              children: [
                Expanded(
                  child: PrimaryElevatedButton(
                    text: 'Cancel',
                    onTap: () => AppRouterGo.back(),
                    backgroundColor: AppColors.listenerPastBadgeBg,
                    textColor: AppColors.primaryWhite,
                    height: 48.h,
                  ),
                ),
                16.pw,
                Expanded(
                  child: PrimaryElevatedButton(
                    text: 'Delete',
                    onTap: () {
                      AppRouterGo.back();
                      onConfirm();
                    },
                    backgroundColor: AppColors.artistEndSessionRed,
                    textColor: AppColors.primaryWhite,
                    height: 48.h,
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
