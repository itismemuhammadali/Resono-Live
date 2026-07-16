import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class ReviewRow extends StatelessWidget {
  const ReviewRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: AppColors.huegrey,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        4.ph,
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: AppColors.primaryWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
