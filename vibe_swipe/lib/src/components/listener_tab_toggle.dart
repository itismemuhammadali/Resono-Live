import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class ListenerTabItem {
  final String label;
  final IconData? icon;

  const ListenerTabItem({required this.label, this.icon});
}

class ListenerTabToggle extends StatelessWidget {
  const ListenerTabToggle({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.containerColor = AppColors.listenerChipBg,
    this.showBorder = true,
    this.containerRadius = 12,
    this.tabRadius = 10,
    this.tabVerticalPadding = 10,
  });

  final List<ListenerTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color containerColor;
  final bool showBorder;
  final double containerRadius;
  final double tabRadius;
  final double tabVerticalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(containerRadius.r),
        border: showBorder
            ? Border.all(
                color: AppColors.listenerBackButtonBorder,
                width: 1.w,
              )
            : null,
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (i) => _Tab(
            item: tabs[i],
            isActive: selectedIndex == i,
            inactiveColor: containerColor,
            tabRadius: tabRadius,
            tabVerticalPadding: tabVerticalPadding,
            onTap: () => onChanged(i),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.item,
    required this.isActive,
    required this.inactiveColor,
    required this.tabRadius,
    required this.tabVerticalPadding,
    required this.onTap,
  });

  final ListenerTabItem item;
  final bool isActive;
  final Color inactiveColor;
  final double tabRadius;
  final double tabVerticalPadding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: tabVerticalPadding.h),
          decoration: BoxDecoration(
            color: isActive ? AppColors.listenerYellow : Colors.transparent,
            borderRadius: BorderRadius.circular(tabRadius.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 16.sp,
                  color: isActive
                      ? AppColors.primaryblack
                      : AppColors.coolGray,
                ),
                6.pw,
              ],
              Text(
                item.label,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppColors.primaryblack
                      : AppColors.primaryWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
