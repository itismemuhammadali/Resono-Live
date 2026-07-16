import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class ArtistPrivacyInfoCard extends StatelessWidget {
  const ArtistPrivacyInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.listenerPastBadgeBg.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline,
            color: AppColors.listenerYellow,
            size: 24.sp,
          ),
          10.pw,
          Expanded(
            child: Text(
              'Your privacy is important to us. You have full control over what information is visible on your profile.',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.huegrey,
                fontFamily: 'Roboto',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
