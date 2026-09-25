import 'package:vibe_swipe/src/core/services/in_app_purchase_service.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/components/in_app_alert.dart';
import '../controllers/tipping_controller.dart';

class TipArtistBottomSheet extends ConsumerStatefulWidget {
  const TipArtistBottomSheet({
    super.key,
    required this.artistName,
    required this.artistId,
  });

  final String artistName;
  final String artistId;

  static void show(
    BuildContext context, {
    required String artistName,
    required String artistId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TipArtistBottomSheet(
        artistName: artistName,
        artistId: artistId,
      ),
    );
  }

  @override
  ConsumerState<TipArtistBottomSheet> createState() =>
      _TipArtistBottomSheetState();
}

class _TipArtistBottomSheetState extends ConsumerState<TipArtistBottomSheet> {
  SuperChatBadge _selectedBadge = SuperChatBadge.allBadges[1]; // Default to Silver ($5)

  Future<void> _onTip() async {
    final ctrl = ref.read(tippingControllerProvider.notifier);
    final success = await ctrl.processTip(
      amount: _selectedBadge.price,
      artistId: widget.artistId,
      artistName: widget.artistName,
      badge: _selectedBadge,
    );

    if (mounted) {
      Navigator.of(context).pop();
      if (success) {
        InAppAlert.show(
          context,
          message:
              '${_selectedBadge.name} tip of \$${_selectedBadge.price.toStringAsFixed(0)} sent to ${widget.artistName}!',
          isSuccess: true,
        );
      } else if (ctrl.paymentError != null) {
        InAppAlert.show(
          context,
          message: ctrl.paymentError ?? 'Payment failed. Please try again.',
          isSuccess: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(tippingControllerProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.listenerDashboardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.santagrey,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          18.ph,
          Row(
            children: [
              Icon(
                Icons.volunteer_activism_rounded,
                color: AppColors.listenerYellow,
                size: 24.sp,
              ),
              8.pw,
              Text(
                'Tip ${widget.artistName}',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryWhite,
                ),
              ),
            ],
          ),
          6.ph,
          Text(
            'Support ${widget.artistName} with an in-app tip badge',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13.sp,
              color: AppColors.santagrey,
            ),
          ),
          20.ph,

          // Badges Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 2.15,
            ),
            itemCount: SuperChatBadge.allBadges.length,
            itemBuilder: (context, index) {
              final badge = SuperChatBadge.allBadges[index];
              final isSelected = _selectedBadge.id == badge.id;

              return GestureDetector(
                onTap: () => setState(() => _selectedBadge = badge),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: badge.colors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : AppColors.listenerChipBg,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : AppColors.listenerChipBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : badge.colors.first.withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          badge.icon,
                          color: isSelected ? Colors.white : badge.colors.first,
                          size: 18.sp,
                        ),
                      ),
                      8.pw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${badge.name} • \$${badge.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.primaryWhite,
                              ),
                            ),
                            2.ph,
                            Text(
                              '${badge.pinMinutes} min alert',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 10.sp,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : AppColors.santagrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          24.ph,
          PrimaryElevatedButton(
            onTap: !controller.isProcessing ? _onTip : () {},
            text: controller.isProcessing
                ? 'Processing Tip...'
                : 'Send ${_selectedBadge.name} Tip (\$${_selectedBadge.price.toStringAsFixed(0)})',
            loader: controller.isProcessing,
            backgroundColor: _selectedBadge.colors.first,
            textColor: Colors.white,
            radius: 14.r,
            enabled: !controller.isProcessing,
          ),
          12.ph,
          Center(
            child: Text(
              'Secure purchase via App Store / Google Play',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 11.sp,
                color: AppColors.santagrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
