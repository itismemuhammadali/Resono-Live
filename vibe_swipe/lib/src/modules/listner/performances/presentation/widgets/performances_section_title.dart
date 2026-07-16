import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class PerformancesSectionTitle extends StatelessWidget {
  const PerformancesSectionTitle({
    super.key,
    required this.image,
    required this.title,
  });

  final String image;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(image, color: AppColors.listenerYellow),
        6.pw,
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryWhite,
          ),
        ),
      ],
    );
  }
}
