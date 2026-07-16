import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/components/custom_textfield.dart';
import '../controllers/artist_performances_controller.dart';

class TagInputRow extends StatelessWidget {
  const TagInputRow({super.key, required this.controller, required this.ref});

  final ArtistPerformancesController controller;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: CustomTextField(
            controller: controller.tagController,
            hintText: 'Add tags',
            isLast: true,
            fillColor: const Color(0xFF121821),
            fieldBorderRadius: 16,
            borderWidth: 1.09,
            enableBorderColor: Colors.white.withValues(alpha: 0.10),
            focusedBorderColor: Colors.white.withValues(alpha: 0.25),
            cursorColor: AppColors.primaryWhite,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 20.h,
            ),
            textStyle: TextStyle(
              fontFamily: 'Roboto',
              color: AppColors.primaryWhite,
              fontSize: 14.sp,
            ),
            onFieldSubmitted: (_) =>
                ref.read(artistPerformancesControllerProvider).addTag(),
          ),
        ),
        10.pw,
        Expanded(
          child: PrimaryElevatedButton(
            onTap: () =>
                ref.read(artistPerformancesControllerProvider).addTag(),
            text: 'Add',
            height: 59.h,
            radius: 16,
            buttonStyle: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.listenerActiveTab,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
