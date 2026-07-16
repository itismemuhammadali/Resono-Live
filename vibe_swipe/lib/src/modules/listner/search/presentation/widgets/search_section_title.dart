import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class SearchSectionTitle extends StatelessWidget {
  const SearchSectionTitle({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
  });
  final Color iconColor;
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18.sp),
        8.pw,
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryWhite,
          ),
        ),
      ],
    );
  }
}
