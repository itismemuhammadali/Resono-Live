import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class PayoutRequiredDialog {
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.listenerDashboardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(
            color: AppColors.listenerChipBorder,
            width: 1,
          ),
        ),
        contentPadding: EdgeInsets.all(24.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.listenerYellow.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_rounded,
                color: AppColors.listenerYellow,
                size: 28.sp,
              ),
            ),
            16.ph,
            Text(
              'Bank Account Required',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryWhite,
              ),
            ),
            10.ph,
            Text(
              'To sell tickets and charge fans for live streams, you must first connect your bank account via Stripe Express to receive your payouts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13.sp,
                color: AppColors.santagrey,
                height: 1.4,
              ),
            ),
            24.ph,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  AppRouterGo.push(artistWalletSetupView);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.listenerYellow,
                  foregroundColor: AppColors.primaryblack,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Connect Bank Account',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            10.ph,
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Keep Free for Now',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13.sp,
                  color: AppColors.santagrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
