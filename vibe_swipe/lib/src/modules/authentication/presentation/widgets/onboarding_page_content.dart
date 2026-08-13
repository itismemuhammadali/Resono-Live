// ignore_for_file: deprecated_member_use

import '../../../../core/utils/app_exports.dart';

class OnboardingPageContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? image;
  final String? feature;

  const OnboardingPageContent({
    super.key,
    required this.title,
    required this.subtitle,
    this.image,
    this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(image!, fit: BoxFit.cover),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 400.h,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF11151E).withOpacity(0.6),
                  const Color(0xFF11151E).withOpacity(0.9),
                  const Color(0xFF11151E),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 24.w,
          right: 24.w,
          bottom: 165.h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (feature != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.listenerActiveTab.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.listenerActiveTab.withOpacity(0.3)),
                  ),
                  child: Text(
                    feature!,
                    style: TextStyle(
                      color: AppColors.listenerActiveTab,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                16.ph,
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.primaryWhite,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              12.ph,
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.subtitleGray,
                  fontSize: 14.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
