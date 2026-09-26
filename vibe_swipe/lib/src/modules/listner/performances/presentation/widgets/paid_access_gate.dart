import 'package:vibe_swipe/src/core/services/in_app_purchase_service.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/components/in_app_alert.dart';
import '../controllers/tipping_controller.dart';

class PaidAccessGate extends ConsumerWidget {
  const PaidAccessGate({
    super.key,
    required this.title,
    required this.artistName,
    required this.artistId,
    required this.performanceId,
    required this.price,
    this.tierNumber,
  });

  final String title;
  final String artistName;
  final String artistId;
  final String performanceId;
  final double price;
  final int? tierNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(tippingControllerProvider);
    final tier = tierNumber != null
        ? TicketTier.fromTierNumber(tierNumber)
        : TicketTier.fromPrice(price);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryblack.withValues(alpha: 0.9),
            AppColors.primaryblack.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.listenerYellow.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.listenerYellow.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.confirmation_number_outlined,
                  color: AppColors.listenerYellow,
                  size: 36.sp,
                ),
              ),
              20.ph,
              Text(
                'LIVE STREAM TICKET REQUIRED',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.listenerYellow,
                  letterSpacing: 1.5,
                ),
              ),
              10.ph,
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryWhite,
                ),
                textAlign: TextAlign.center,
              ),
              6.ph,
              Text(
                'by $artistName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 15.sp,
                  color: AppColors.santagrey,
                ),
              ),
              24.ph,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.listenerChipBg,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.listenerYellow.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      tier.fullName,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryWhite.withValues(alpha: 0.9),
                      ),
                    ),
                    4.ph,
                    Text(
                      price > 0 ? '\$${price.toStringAsFixed(2)}' : tier.formattedPrice,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.listenerYellow,
                      ),
                    ),
                  ],
                ),
              ),
              24.ph,
              PrimaryElevatedButton(
                onTap: controller.isProcessing
                    ? () {}
                    : () async {
                        final success = await ref
                            .read(tippingControllerProvider.notifier)
                            .unlockPerformance(
                              amount: price > 0 ? price : tier.price,
                              artistId: artistId,
                              performanceId: performanceId,
                              tierNumber: tier.tierNumber,
                            );
                        if (context.mounted) {
                          if (success) {
                            InAppAlert.show(
                              context,
                              message: 'Ticket purchased! Access granted.',
                              isSuccess: true,
                            );
                          } else {
                            InAppAlert.show(
                              context,
                              message: controller.paymentError ??
                                  'Purchase failed or was cancelled.',
                              isSuccess: false,
                            );
                          }
                        }
                      },
                text: controller.isProcessing
                    ? 'Processing Purchase...'
                    : 'Get ${tier.name} Ticket (\$${tier.price.toStringAsFixed(0)})',
                loader: controller.isProcessing,
                backgroundColor: AppColors.listenerYellow,
                textColor: AppColors.primaryblack,
                radius: 14.r,
                enabled: !controller.isProcessing,
              ),
              12.ph,
              Text(
                'One-time purchase via App Store / Google Play to access this live show',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 11.sp,
                  color: AppColors.santagrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
