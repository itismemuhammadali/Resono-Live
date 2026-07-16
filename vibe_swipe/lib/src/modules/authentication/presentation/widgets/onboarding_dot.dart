import '../../../../core/utils/app_exports.dart';

class OnboardingDot extends StatelessWidget {
  final int index;
  final int currentPage;

  const OnboardingDot({
    super.key,
    required this.index,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(right: 6.w),
      height: 6.h,
      width: currentPage == index ? 24.w : 6.w,
      decoration: BoxDecoration(
        color: currentPage == index
            ? AppColors.listenerYellow
            : AppColors.inactiveDot,
        borderRadius: BorderRadius.circular(3.r),
      ),
    );
  }
}
