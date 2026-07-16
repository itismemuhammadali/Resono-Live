import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/components/in_app_alert.dart';
import 'package:vibe_swipe/src/core/services/live_chat_service.dart';
import '../controllers/tipping_controller.dart';

class SuperChatBottomSheet extends ConsumerStatefulWidget {
  final String artistId;
  final String artistName;
  final String performanceId;

  const SuperChatBottomSheet({
    super.key,
    required this.artistId,
    required this.artistName,
    required this.performanceId,
  });

  static void show(BuildContext context, {
    required String artistId,
    required String artistName,
    required String performanceId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SuperChatBottomSheet(
        artistId: artistId,
        artistName: artistName,
        performanceId: performanceId,
      ),
    );
  }

  @override
  ConsumerState<SuperChatBottomSheet> createState() => _SuperChatBottomSheetState();
}

class _SuperChatBottomSheetState extends ConsumerState<SuperChatBottomSheet> {
  double _selectedAmount = 10.0;
  final _messageController = TextEditingController();
  bool _isCustom = false;
  final _customAmountController = TextEditingController();

  static const _presetAmounts = [5.0, 10.0, 25.0, 50.0];

  @override
  void dispose() {
    _messageController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(tippingControllerProvider);

    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: AppColors.listenerDashboardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
            Row(
              children: [
                Icon(Icons.star, color: AppColors.superChatGold, size: 24.sp),
                8.pw,
                Text(
                  'Super Chat',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryWhite,
                  ),
                ),
              ],
            ),
            8.ph,
            Text(
              'Send a highlighted message to ${widget.artistName}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    AppColors.superChatGold,
                                    AppColors.superChatGoldDark,
                                  ],
                                )
                              : null,
                          color: isSelected ? null : AppColors.listenerChipBg,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.superChatGold
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
                  color: _isCustom ? AppColors.listenerChipBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _isCustom
                        ? AppColors.superChatGold
                        : AppColors.listenerChipBorder,
                  ),
                ),
                child: TextField(
                  controller: _customAmountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
            16.ph,
            TextField(
              controller: _messageController,
              maxLength: 100,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14.sp,
                color: AppColors.primaryWhite,
              ),
              decoration: InputDecoration(
                hintText: 'Add a message (required)',
                hintStyle: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.santagrey,
                ),
                counterStyle: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.santagrey,
                ),
                filled: true,
                fillColor: AppColors.listenerChipBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.listenerChipBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.superChatGold),
                ),
              ),
            ),
            24.ph,
            PrimaryElevatedButton(
              onTap: _canSend() && !controller.isProcessing ? _onSend : () {},
              text: controller.isProcessing
                  ? 'Processing...'
                  : 'Send \$${_effectiveAmount.toStringAsFixed(2)} Super Chat',
              loader: controller.isProcessing,
              backgroundColor: AppColors.superChatGold,
              textColor: AppColors.primaryblack,
              radius: 14,
              enabled: _canSend() && !controller.isProcessing,
            ),
          ],
        ),
      ),
    );
  }

  double get _effectiveAmount {
    if (_isCustom) return double.tryParse(_customAmountController.text) ?? 0;
    return _selectedAmount;
  }

  bool _canSend() => _effectiveAmount > 0 && _messageController.text.trim().isNotEmpty;

  Future<void> _onSend() async {
    final success = await ref.read(tippingControllerProvider.notifier).processTip(
      amount: _effectiveAmount,
      artistId: widget.artistId,
      artistName: widget.artistName,
    );

    if (success && mounted) {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final userName = FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous';
      await LiveChatService.sendMessage(
        performanceId: widget.performanceId,
        text: _messageController.text.trim(),
        senderId: userId,
        senderName: userName,
        isSuperChat: true,
        donationAmount: _effectiveAmount,
      );
      Navigator.of(context).pop();
      InAppAlert.show(
        context,
        message: 'Super Chat sent!',
        isSuccess: true,
      );
    } else if (mounted) {
      Navigator.of(context).pop();
      InAppAlert.show(
        context,
        message: 'Payment failed. Please try again.',
        isSuccess: false,
      );
    }
  }
}
