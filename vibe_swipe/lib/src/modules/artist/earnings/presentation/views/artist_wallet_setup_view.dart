import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vibe_swipe/src/core/theme/app_colors.dart';
import 'package:vibe_swipe/src/core/utils/app_extensions.dart';
import 'package:vibe_swipe/src/core/services/routing_service/named_routes.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import '../controllers/artist_earnings_controller.dart';

class ArtistWalletSetupView extends ConsumerWidget {
  const ArtistWalletSetupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(artistEarningsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryWhite),
          onPressed: () => AppRouterGo.back(),
        ),
        title: Text(
          'Payout Settings',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryWhite,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.listenerChipBg,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.listenerChipBorder),
                ),
                child: Column(
                  children: [
                    Icon(
                      controller.stripePayoutsEnabled
                          ? Icons.check_circle_rounded
                          : Icons.account_balance_rounded,
                      color: controller.stripePayoutsEnabled
                          ? Colors.green
                          : AppColors.listenerYellow,
                      size: 48.sp,
                    ),
                    16.ph,
                    Text(
                      controller.stripePayoutsEnabled
                          ? 'Stripe Account Connected'
                          : 'Connect Stripe Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryWhite,
                      ),
                    ),
                    8.ph,
                    Text(
                      controller.stripePayoutsEnabled
                          ? 'Your Stripe account is fully set up and ready to receive payouts. You can withdraw your earnings directly to your bank account.'
                          : 'VibeSwipe uses Stripe to securely process your payouts. Connect your account to start receiving earnings directly to your bank.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.sp,
                        color: AppColors.santagrey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              20.ph,
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: AppColors.listenerChipBg,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.listenerChipBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_long_rounded, color: AppColors.listenerYellow, size: 20.sp),
                        8.pw,
                        Text(
                          'Fee Breakdown',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryWhite,
                          ),
                        ),
                      ],
                    ),
                    14.ph,
                    const _FeeRow(label: 'Store Fee (Apple / Google)', percentage: '15%'),
                    10.ph,
                    const _FeeRow(label: 'VibeSwipe Platform Fee', percentage: '10%'),
                    10.ph,
                    const _FeeRow(label: 'Stripe Payout Fee', percentage: '2.5% – 3%'),
                    14.ph,
                    Text(
                      'Store and platform fees are deducted automatically from in-app tickets and tips. Standard Stripe processing fees apply upon transferring funds to your bank.',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.sp,
                        color: AppColors.santagrey,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              24.ph,
              if (!controller.stripePayoutsEnabled)
                PrimaryElevatedButton(
                  onTap: () {
                    ref.read(artistEarningsControllerProvider.notifier).setupStripeConnect();
                  },
                  text: 'Connect with Stripe',
                  loader: controller.isLoading,
                  backgroundColor: AppColors.listenerYellow,
                  textColor: AppColors.primaryblack,
                  radius: 14,
                )
              else
                PrimaryElevatedButton(
                  onTap: () {
                    AppRouterGo.back();
                  },
                  text: 'Done',
                  backgroundColor: AppColors.listenerChipBg,
                  textColor: AppColors.primaryWhite,
                  radius: 14,
                ),
              
              if (controller.stripeAccountId != null && !controller.stripePayoutsEnabled) ...[
                16.ph,
                PrimaryElevatedButton(
                  onTap: () {
                    ref.read(artistEarningsControllerProvider.notifier).checkStripeStatus();
                  },
                  text: 'Refresh Status',
                  loader: controller.isLoading,
                  backgroundColor: AppColors.listenerChipBg,
                  textColor: AppColors.primaryWhite,
                  radius: 14,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  const _FeeRow({required this.label, required this.percentage});
  final String label;
  final String percentage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 13.sp,
            color: AppColors.santagrey,
          ),
        ),
        Text(
          percentage,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryWhite,
          ),
        ),
      ],
    );
  }
}
