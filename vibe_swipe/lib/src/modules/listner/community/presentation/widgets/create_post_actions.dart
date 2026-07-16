import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class CreatePostActions extends StatelessWidget {
  const CreatePostActions({
    super.key,
    required this.onPublish,
    required this.onCancel,
    this.isPublishing = false,
  });

  final VoidCallback onPublish;
  final VoidCallback onCancel;
  final bool isPublishing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Column(
        children: [
          PrimaryElevatedButton(
            text: isPublishing ? 'Publishing...' : 'Publish Post',
            onTap: isPublishing ? () {} : onPublish,
            loader: isPublishing,
            backgroundColor: AppColors.listenerYellow,
            textColor: AppColors.primaryblack,
            radius: 14,
          ),
          12.ph,
          PrimaryElevatedButton(
            text: 'Cancel',
            onTap: isPublishing ? () {} : onCancel,
            backgroundColor: AppColors.transparent,
            textColor: AppColors.primaryWhite,
            radius: 14,
            enabled: !isPublishing,
            buttonStyle: ElevatedButton.styleFrom(
              backgroundColor: AppColors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
                side: const BorderSide(
                  color: AppColors.listenerBackButtonBorder,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
