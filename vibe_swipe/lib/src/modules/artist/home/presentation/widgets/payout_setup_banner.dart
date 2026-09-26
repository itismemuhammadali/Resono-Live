import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class PayoutSetupBanner extends StatelessWidget {
  const PayoutSetupBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.listenerYellow.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.listenerYellow.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.listenerYellow,
                  size: 20.sp,
                ),
              ),
              12.pw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set Up Payout Account',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryWhite,
                      ),
                    ),
                    2.ph,
                    Text(
                      'Required to host paid streams & withdraw earnings',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.sp,
                        color: AppColors.santagrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          12.ph,
          Text(
            'Connect your bank account via Stripe Express to enable paid tickets and receive payouts from fans.',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13.sp,
              color: AppColors.primaryWhite.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          14.ph,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => AppRouterGo.push(artistWalletSetupView),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.listenerYellow,
                foregroundColor: AppColors.primaryblack,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
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
        ],
      ),
    );
  }
}
