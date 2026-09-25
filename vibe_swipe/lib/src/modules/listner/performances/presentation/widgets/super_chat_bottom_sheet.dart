import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibe_swipe/src/core/services/in_app_purchase_service.dart';
import 'package:vibe_swipe/src/core/services/live_chat_service.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/components/in_app_alert.dart';
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

  static void show(
    BuildContext context, {
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
  ConsumerState<SuperChatBottomSheet> createState() =>
      _SuperChatBottomSheetState();
}

class _SuperChatBottomSheetState extends ConsumerState<SuperChatBottomSheet> {
  SuperChatBadge _selectedBadge = SuperChatBadge.allBadges[1]; // Default to Silver ($5)
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  bool get _canSend => _messageController.text.trim().isNotEmpty;

  Future<void> _onSend() async {
    if (!_canSend) return;

    final controller = ref.read(tippingControllerProvider.notifier);
    final success = await controller.processTip(
      amount: _selectedBadge.price,
      artistId: widget.artistId,
      artistName: widget.artistName,
      performanceId: widget.performanceId,
      message: _messageController.text.trim(),
      badge: _selectedBadge,
    );

    if (success && mounted) {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final userName =
          FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous';

      await LiveChatService.sendMessage(
        performanceId: widget.performanceId,
        text: _messageController.text.trim(),
        senderId: userId,
        senderName: userName,
        isSuperChat: true,
        donationAmount: _selectedBadge.price,
        badge: _selectedBadge.id,
      );

      if (mounted) {
        Navigator.of(context).pop();
        InAppAlert.show(
          context,
          message:
              '${_selectedBadge.name} Super Chat sent to ${widget.artistName}!',
          isSuccess: true,
        );
      }
    } else if (mounted) {
      Navigator.of(context).pop();
      InAppAlert.show(
        context,
        message: 'Payment was not completed. Please try again.',
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(tippingControllerProvider);
    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
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
      child: SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  Icons.stars_rounded,
                  color: AppColors.superChatGold,
                  size: 26.sp,
                ),
                8.pw,
                Text(
                  'Super Chat Badges',
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
              'Select a tip badge to send a highlighted message to ${widget.artistName}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13.sp,
                color: AppColors.santagrey,
              ),
            ),
            20.ph,

            // 4 Tip Badges Grid
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
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: badge.colors.first
                                    .withValues(alpha: 0.35),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
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
                                '${badge.pinMinutes} min pin',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : AppColors.santagrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            18.ph,

            // Message TextField
            TextField(
              controller: _messageController,
              maxLength: 100,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14.sp,
                color: AppColors.primaryWhite,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText:
                    'Say something to ${widget.artistName} (required)...',
                hintStyle: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13.sp,
                  color: AppColors.santagrey,
                ),
                counterStyle: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 11.sp,
                  color: AppColors.santagrey,
                ),
                filled: true,
                fillColor: AppColors.listenerChipBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide:
                      BorderSide(color: AppColors.listenerChipBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(
                    color: _selectedBadge.colors.first,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            20.ph,

            // Buy Super Chat Button
            PrimaryElevatedButton(
              onTap: _canSend && !controller.isProcessing ? _onSend : () {},
              text: controller.isProcessing
                  ? 'Processing Purchase...'
                  : 'Send ${_selectedBadge.name} Super Chat (\$${_selectedBadge.price.toStringAsFixed(0)})',
              loader: controller.isProcessing,
              backgroundColor: _selectedBadge.colors.first,
              textColor: Colors.white,
              radius: 14.r,
              enabled: _canSend && !controller.isProcessing,
            ),
            10.ph,
            Center(
              child: Text(
                'Purchased via Apple App Store / Google Play In-App Purchase',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 11.sp,
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
