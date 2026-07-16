import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class HelpSectionLabel extends StatelessWidget {
  const HelpSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryWhite,
        fontFamily: 'Roboto',
        height: 1.0,
      ),
    );
  }
}
