import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class EditSectionLabel extends StatelessWidget {
  const EditSectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Roboto',
        color: AppColors.primaryWhite,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
