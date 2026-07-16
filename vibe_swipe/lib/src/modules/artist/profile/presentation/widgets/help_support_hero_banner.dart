import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class HelpSupportHeroBanner extends StatelessWidget {
  const HelpSupportHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.listenerYellow.withValues(alpha: 0.20),
            AppColors.listenerYellow.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border(
          top: BorderSide(
            color: AppColors.listenerYellow.withValues(alpha: 0.20),
            width: 1.09,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.help_outline_rounded,
            color: AppColors.listenerYellow,
            size: 48.sp,
          ),
          10.ph,
          Text(
            'How can we help you?',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryWhite,
            ),
          ),
          10.ph,
          Text(
            'Find answers to common questions or contact our support team',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.huegrey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
