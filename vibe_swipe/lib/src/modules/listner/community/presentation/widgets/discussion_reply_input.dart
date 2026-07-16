import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/custom_textfield.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';

class DiscussionReplyInput extends StatefulWidget {
  const DiscussionReplyInput({
    super.key,
    required this.replyController,
    required this.onPost,
  });

  final TextEditingController replyController;
  final VoidCallback onPost;

  @override
  State<DiscussionReplyInput> createState() => _DiscussionReplyInputState();
}

class _DiscussionReplyInputState extends State<DiscussionReplyInput> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFF121821),
        borderRadius: BorderRadius.circular(16.r),
        border: Border(
          top: BorderSide(color: const Color(0xFF1F2937), width: 1.09),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add a reply',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryWhite,
              ),
            ),
            10.ph,
            CustomTextField(
              controller: widget.replyController,
              hintText: 'Share your thoughts...',
              minLines: 4,
              maxLines: null,
              fillColor: const Color(0xFF0B0F14),
              enableBorderColor: const Color(0xFF1F2937),
              focusedBorderColor: AppColors.listenerYellow,
              fieldBorderRadius: 16,
              borderWidth: 1.09,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
              textStyle: TextStyle(
                color: AppColors.primaryWhite,
                fontSize: 14.sp,
                fontFamily: 'Roboto',
              ),
              hintTextStyle: TextStyle(
                color: AppColors.hintGray,
                fontSize: 16.sp,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                height: 24 / 16,
                letterSpacing: 0,
              ),
              isLast: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Reply cannot be empty';
                }
                if (value.trim().length < 3) {
                  return 'Reply must be at least 3 characters';
                }
                if (value.trim().length > 500) {
                  return 'Reply must be under 500 characters';
                }
                return null;
              },
            ),
            10.ph,
            PrimaryElevatedButton(
              onTap: () {
                if (_formKey.currentState?.validate() ?? false) {
                  widget.onPost();
                }
              },
              text: 'Post Reply',
              backgroundColor: AppColors.listenerYellow,
              textColor: AppColors.primaryblack,
              height: 52.h,
              radius: 12,
              leadingWidget: Image.asset(
                'assets/icons/png/post_reply_btn_icn.png',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
