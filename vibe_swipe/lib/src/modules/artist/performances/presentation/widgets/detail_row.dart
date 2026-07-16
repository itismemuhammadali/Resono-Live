import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.huegrey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryWhite,
          ),
        ),
      ],
    );
  }
}
