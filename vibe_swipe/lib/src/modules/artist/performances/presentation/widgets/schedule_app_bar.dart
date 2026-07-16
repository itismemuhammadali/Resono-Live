import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/auth_step_progress.dart';
import 'package:vibe_swipe/src/modules/authentication/presentation/widgets/auth_back_button.dart';

class ScheduleAppBar extends StatelessWidget {
  const ScheduleAppBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.title = 'Schedule Live Session',
  });

  final int currentStep;
  final int totalSteps;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/png/app_background_image.png'),
          fit: BoxFit.cover,
        ),
        border: const Border(
          bottom: BorderSide(color: AppColors.listenerChipBg, width: 1),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: 16.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthBackButton(),
              12.ph,
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.primaryWhite,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              6.ph,
              Text(
                'Step $currentStep of $totalSteps',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.huegrey,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              10.ph,
              AuthStepProgress(currentStep: currentStep, totalSteps: totalSteps),
            ],
          ),
        ),
      ),
    );
  }
}
