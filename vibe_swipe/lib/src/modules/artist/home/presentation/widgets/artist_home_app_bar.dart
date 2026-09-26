import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class ArtistHomeAppBar extends StatelessWidget {
  const ArtistHomeAppBar({super.key, required this.artistName});

  final String artistName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 126.h),
      padding: EdgeInsets.only(
        // top: 20.h,
        left: 20.w,
        right: 20.w,
        bottom: 16.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.artistHomeAppBarBg,
        border: const Border(
          bottom: BorderSide(color: AppColors.listenerNavBorder, width: 1),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryblack.withValues(alpha: 0.35),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryWhite,
                    ),
                  ),
                  4.ph,
                  Text(
                    artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.listenerActiveTab,
                    ),
                  ),
                ],
              ),
            ),
            16.pw,
            GestureDetector(
              onTap: () => AppRouterGo.push(artistEarningsView),
              child: SizedBox(
                width: 40.w,
                height: 40.w,
                child: Center(
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.primaryWhite,
                    size: 24.sp,
                  ),
                ),
              ),
            ),
            8.pw,
            GestureDetector(
              onTap: () => AppRouterGo.push(artistNotificationsView),
              child: const _NotificationBell(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Image.asset(
              AppAssetsPng.profileNotificationTabIcn,
              width: 24.w,
              height: 24.w,
              color: AppColors.primaryWhite,
            ),
          ),
          Positioned(
            top: 6.h,
            right: 4.w,
            child: Container(
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                color: AppColors.listenerActiveTab,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
