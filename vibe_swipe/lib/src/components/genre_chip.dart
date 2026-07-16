import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class GenreChip extends StatelessWidget {
  const GenreChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor = AppColors.listenerYellow,
    this.selectedTextColor = AppColors.primaryblack,
    this.isDisabled = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color selectedTextColor;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.35 : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : AppColors.listenerChipBg,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected ? selectedColor : AppColors.listenerChipBorder,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Roboto',
              color: isSelected ? selectedTextColor : AppColors.primaryWhite,
              fontSize: 16.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
