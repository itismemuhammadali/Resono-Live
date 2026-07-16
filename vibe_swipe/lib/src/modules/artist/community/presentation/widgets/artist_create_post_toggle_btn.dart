import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class ArtistCreatePostToggleBtn extends StatelessWidget {
  const ArtistCreatePostToggleBtn({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.asset,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? AppColors.listenerActiveTab
        : AppColors.listenerChipBg;
    final fg = isSelected ? AppColors.primaryblack : AppColors.primaryWhite;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? AppColors.listenerActiveTab
                : AppColors.primaryWhite.withValues(alpha: 0.10),
            width: 1.09,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (asset != null) ...[Image.asset(asset ?? '', color: fg), 4.pw],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
