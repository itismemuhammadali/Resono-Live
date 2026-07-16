import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class PrivacyInfoCard extends StatelessWidget {
  const PrivacyInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 17.h),
      decoration: BoxDecoration(
        color: const Color(0xFF121821),
        borderRadius: 16.circular,
        border: Border.all(
          color: const Color(0xFFFFD426).withValues(alpha: 0.30),
          width: 1.09.w,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: AppColors.listenerYellow,
            size: 24.sp,
          ),
          14.pw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Privacy Matters',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryWhite,
                    fontFamily: 'Roboto',
                  ),
                ),
                6.ph,
                Text(
                  'Control who can see your activity and how your data is used',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.huegrey,
                    fontFamily: 'Roboto',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
