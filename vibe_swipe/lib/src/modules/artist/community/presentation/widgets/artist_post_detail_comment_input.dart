import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/custom_textfield.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';

class ArtistPostDetailCommentInput extends StatelessWidget {
  const ArtistPostDetailCommentInput({
    super.key,
    required this.controller,
    this.onSubmit,
  });

  final TextEditingController controller;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryWhite.withValues(alpha: 0.10),
          width: 1.09.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100.h,
            child: CustomTextField(
              controller: controller,
              hintText: 'Write a comment...',
              minLines: 3,
              maxLines: null,
              fillColor: AppColors.listenerDashboardBg,
              fieldBorderRadius: 16,
              borderWidth: 1.09,
              enableBorderColor: AppColors.primaryWhite.withValues(alpha: 0.10),
              focusedBorderColor: AppColors.primaryWhite.withValues(alpha: 0.10),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              textStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryWhite,
              ),
              hintTextStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.huegrey,
              ),
              isLast: true,
            ),
          ),
          16.ph,
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final isEmpty = value.text.trim().isEmpty;
              return Align(
                alignment: Alignment.centerLeft,
                child: PrimaryElevatedButton(
                  onTap: () => onSubmit?.call(),
                  text: 'Reply',
                  enabled: !isEmpty,
                  disableButtonTextColor: AppColors.black,
                  buttonStyle: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: 14.circular),
                    backgroundColor: AppColors.listenerActiveTab,
                    disabledBackgroundColor: AppColors.listenerActiveTab
                        .withValues(alpha: 0.25),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  ),
                  width: 120.w,
                  height: 42.h,
                  radius: 14.r,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  leadingWidget: Image.asset(
                    'assets/icons/png/post_reply_btn_icn.png',
                    width: 14.h,
                    height: 14.h,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
