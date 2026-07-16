import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class HelpSupportLiveChatTile extends StatelessWidget {
  const HelpSupportLiveChatTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryWhite.withValues(alpha: 0.10),
          width: 1.09,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: AppColors.listenerYellow.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/icons/png/artist_community_trending_discussions.png',
            ),
          ),
          16.pw,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Live Chat',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryWhite,
                ),
              ),
              4.ph,
              Text(
                'Chat with our support team',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.huegrey,
                ),
              ),
              8.ph,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.listenerActiveTab.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.listenerActiveTab,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
