import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class ListenerPageHeader extends StatelessWidget {
  const ListenerPageHeader({super.key, required this.title, this.onBack, this.trailing});

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? AppRouterGo.back,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primaryWhite.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: AppColors.primaryWhite.withValues(alpha: 0.10),
                  width: 1.09.w,
                ),
              ),
              child: Icon(
                Icons.chevron_left,
                color: AppColors.primaryWhite,
                size: 24.sp,
              ),
            ),
          ),
          16.pw,
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryWhite,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          if (trailing != null) ...[
            16.pw,
            trailing!,
          ],
        ],
      ),
    );
  }
}
