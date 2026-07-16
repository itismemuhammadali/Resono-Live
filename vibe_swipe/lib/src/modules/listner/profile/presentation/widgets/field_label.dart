import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.gray300,
        fontFamily: 'Roboto',
      ),
    );
  }
}
