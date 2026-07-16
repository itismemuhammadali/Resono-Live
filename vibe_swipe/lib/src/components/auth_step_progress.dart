import '../core/utils/app_exports.dart';

class AuthStepProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const AuthStepProgress({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        return Expanded(
          child: Container(
            height: 3.h,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 6.w : 0),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.listenerYellow
                  : AppColors.listenerChipBorder,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        );
      }),
    );
  }
}
