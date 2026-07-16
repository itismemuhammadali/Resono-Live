import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class HomeFilterChips extends StatelessWidget {
  const HomeFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = [
      ("assets/icons/png/home_new_filter_icn.png", 'New'),
      ("assets/icons/png/home_trending_filter_icn.png", 'Trending'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: List.generate(filters.length, (i) {
          final isSelected = selected == i;
          return Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.listenerYellow.withValues(alpha: 0.15)
                      : AppColors.listenerChipBg,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.listenerYellow
                        : AppColors.listenerChipBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      filters[i].$1,
                      color: isSelected
                          ? AppColors.listenerYellow
                          : AppColors.snowWhite,
                    ),
                    6.pw,
                    Text(
                      filters[i].$2,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.sp,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppColors.listenerYellow
                            : AppColors.snowWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
