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
  });

  final String title;
  final String artistName;
  final String artistId;
  final String performanceId;
  final double price;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kIsWeb && Platform.isIOS) {
      return const SizedBox.shrink();
    }
    final controller = ref.watch(tippingControllerProvider);

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
                  Icons.lock_rounded,
                  color: AppColors.listenerYellow,
                  size: 36.sp,
                ),
              ),
              24.ph,
              Text(
                'Paid Performance',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.listenerYellow,
                  letterSpacing: 1.5,
                ),
              ),
              12.ph,
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryWhite,
                ),
                textAlign: TextAlign.center,
              ),
              8.ph,
              Text(
                'by $artistName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16.sp,
                  color: AppColors.santagrey,
                ),
              ),
              32.ph,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.listenerChipBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.listenerYellow,
                  ),
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
                              amount: price,
                              artistId: artistId,
                              performanceId: performanceId,
                            );
                        if (context.mounted) {
                          if (success) {
                            InAppAlert.show(
                              context,
                              message: 'Performance unlocked! Enjoy the show.',
                              isSuccess: true,
                            );
                          } else {
                            InAppAlert.show(
                              context,
                              message: 'Payment failed. Please try again.',
                              isSuccess: false,
                            );
                          }
                        }
                      },
                text: controller.isProcessing
                    ? 'Processing...'
                    : 'Unlock Performance',
                loader: controller.isProcessing,
                backgroundColor: AppColors.listenerYellow,
                textColor: AppColors.primaryblack,
                radius: 14.r,
                enabled: !controller.isProcessing,
              ),
              12.ph,
              Text(
                'One-time purchase to access this live performance',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12.sp,
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
