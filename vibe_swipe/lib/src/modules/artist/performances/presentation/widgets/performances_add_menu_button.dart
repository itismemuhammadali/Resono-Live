import 'package:vibe_swipe/src/core/utils/app_exports.dart';

enum _PerformanceQuickAction { scheduleLiveSession, uploadPerformance }

class PerformancesAddMenuButton extends StatelessWidget {
  const PerformancesAddMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_PerformanceQuickAction>(
      onSelected: (action) {
        switch (action) {
          case _PerformanceQuickAction.scheduleLiveSession:
            AppRouterGo.push(artistScheduleLiveSessionView);
          case _PerformanceQuickAction.uploadPerformance:
            AppRouterGo.push(artistUploadVideoView);
        }
      },
      color: AppColors.listenerPopupMenuBg,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      offset: Offset(0, 8.h),
      constraints: BoxConstraints(minWidth: 200.w, maxWidth: 300.w),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _PerformanceQuickAction.scheduleLiveSession,
          child: _MenuOption(
            asset: 'assets/icons/png/artist_home_go_live_icn.png',
            label: 'Schedule Live Session',
          ),
        ),
        PopupMenuItem(
          value: _PerformanceQuickAction.uploadPerformance,
          child: _MenuOption(
            asset: 'assets/icons/png/artist_home_upload_icn.png',
            label: 'Upload Performance',
          ),
        ),
      ],
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: const BoxDecoration(
          color: AppColors.listenerYellow,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add, color: AppColors.primaryblack, size: 22.sp),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  const _MenuOption({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          asset,
          color: AppColors.primaryWhite,
          width: 16.w,
          height: 16.w,
        ),
        10.pw,
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.primaryWhite,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
