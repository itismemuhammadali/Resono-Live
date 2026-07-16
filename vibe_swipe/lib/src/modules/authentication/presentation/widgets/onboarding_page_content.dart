// ignore_for_file: deprecated_member_use

import '../../../../core/utils/app_exports.dart';

class OnboardingPageContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? image;

  const OnboardingPageContent({
    super.key,
    required this.title,
    required this.subtitle,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(image!, fit: BoxFit.cover),
        // Positioned(
        //   left: 0,
        //   right: 0,
        //   bottom: 0,
        //   height: 400.h,
        //   child: Container(
        //     decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //         begin: Alignment.topCenter,
        //         end: Alignment.bottomCenter,
        //         colors: [
        //           Colors.transparent,
        //           const Color(0xFF11151E).withOpacity(0.6),
        //           const Color(0xFF11151E).withOpacity(0.9),
        //           const Color(0xFF11151E),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        Positioned(
          left: 24.w,
          right: 24.w,
          bottom: 130.h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              16.ph,
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.subtitleGray,
                  fontSize: 14.sp,
                  height: 1.5,
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
