import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class CommunityHeader extends StatelessWidget {
  const CommunityHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.snowWhite.withValues(alpha: 0.4),
            width: 1.w,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Community',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryWhite,
            ),
          ),
          const _NewPostButton(),
        ],
      ),
    );
  }
}

class _NewPostButton extends StatelessWidget {
  const _NewPostButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRouterGo.push(listenerCreatePostView),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.listenerYellow,
          borderRadius: BorderRadius.circular(46.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: AppColors.primaryblack, size: 16.sp),
            10.pw,
            Text(
              'New Post',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryblack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
