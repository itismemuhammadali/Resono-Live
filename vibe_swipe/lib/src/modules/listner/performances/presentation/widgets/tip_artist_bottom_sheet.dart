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

  static void show(BuildContext context, {
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
  double _selectedAmount = 10.0;
  final TextEditingController _customAmountController = TextEditingController();
  bool _isCustom = false;

  static const _presetAmounts = [5.0, 10.0, 20.0];

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  double get _effectiveAmount {
    if (_isCustom) {
      return double.tryParse(_customAmountController.text) ?? 0.0;
    }
    return _selectedAmount;
  }

  Future<void> _onTip() async {
    final amount = _effectiveAmount;
    if (amount <= 0) return;

    final ctrl = ref.read(tippingControllerProvider.notifier);
    final success = await ctrl.processTip(
      amount: amount,
      artistId: widget.artistId,
      artistName: widget.artistName,
    );

    if (mounted) {
      Navigator.of(context).pop();
      if (success) {
        InAppAlert.show(
          context,
          message: 'Tip of \$${amount.toStringAsFixed(2)} sent successfully!',
          isSuccess: true,
        );
      } else if (ctrl.paymentError != null) {
        InAppAlert.show(
          context,
          message: 'Payment failed. Please try again.',
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
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
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
          20.ph,
          Text(
            'Tip ${widget.artistName}',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryWhite,
            ),
          ),
          8.ph,
          Text(
            'Show your support with a tip',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14.sp,
              color: AppColors.santagrey,
            ),
          ),
          24.ph,
          Row(
            children: _presetAmounts.map((amount) {
              final isSelected = !_isCustom && _selectedAmount == amount;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedAmount = amount;
                      _isCustom = false;
                    }),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.listenerYellow
                            : AppColors.listenerChipBg,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.listenerYellow
                              : AppColors.listenerChipBorder,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '\$${amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primaryblack
                                : AppColors.primaryWhite,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          16.ph,
          GestureDetector(
            onTap: () => setState(() => _isCustom = true),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _isCustom
                    ? AppColors.listenerChipBg
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _isCustom
                      ? AppColors.listenerYellow
                      : AppColors.listenerChipBorder,
                ),
              ),
              child: TextField(
                controller: _customAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16.sp,
                  color: AppColors.primaryWhite,
                ),
                decoration: InputDecoration(
                  hintText: 'Custom amount',
                  hintStyle: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16.sp,
                    color: AppColors.santagrey,
                  ),
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16.sp,
                    color: AppColors.primaryWhite,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          24.ph,
          PrimaryElevatedButton(
            onTap: _effectiveAmount > 0 ? _onTip : () {},
            text: controller.isProcessing
                ? 'Processing...'
                : 'Send \$${_effectiveAmount.toStringAsFixed(2)} Tip',
            loader: controller.isProcessing,
            backgroundColor: AppColors.listenerYellow,
            textColor: AppColors.primaryblack,
            radius: 14,
            enabled: _effectiveAmount > 0 && !controller.isProcessing,
          ),
          12.ph,
        ],
      ),
    );
  }
}
