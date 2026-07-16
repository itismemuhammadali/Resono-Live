import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/core/constants/app_constants.dart';

class EmailSupportTile extends StatelessWidget {
  const EmailSupportTile({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.listenerChipBg,
          borderRadius: 16.circular,
          border: Border.all(
            color: AppColors.primaryWhite.withValues(alpha: 0.06),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: AppColors.listenerYellow,
                borderRadius: 12.circular,
              ),
              child: FittedBox(
                child: Icon(Icons.mail_outline, color: AppColors.primaryblack),
              ),
            ),
            14.pw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email Support',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryWhite,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  4.ph,
                  Text(
                    AppConstants.supportEmail,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.huegrey,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 24.sp, color: AppColors.huegrey),
          ],
        ),
      ),
    );
  }
}
