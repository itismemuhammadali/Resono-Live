import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class HelpSupportSectionLabel extends StatelessWidget {
  const HelpSupportSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryWhite,
      ),
    );
  }
}
