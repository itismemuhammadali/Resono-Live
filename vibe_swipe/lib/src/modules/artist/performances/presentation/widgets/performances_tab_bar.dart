import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class PerformancesTabBar extends StatelessWidget {
  const PerformancesTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = selectedIndex == i;
          return Padding(
            padding: EdgeInsets.only(right: i < tabs.length - 1 ? 10.w : 0),
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 15.w : 17.w,
                  vertical: 9.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.listenerActiveTab
                      : AppColors.listenerChipBg,
                  borderRadius: BorderRadius.circular(16.r),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: AppColors.primaryWhite.withValues(alpha: 0.10),
                          width: 1.09.w,
                        ),
                ),
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryblack
                        : AppColors.primaryWhite,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
