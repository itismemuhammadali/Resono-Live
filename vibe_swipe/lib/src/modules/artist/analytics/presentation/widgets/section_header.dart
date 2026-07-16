import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodSelected,
  });

  final AnalyticsPeriod selectedPeriod;
  final void Function(AnalyticsPeriod) onPeriodSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryWhite,
          ),
        ),
        16.ph,
        _PeriodTabs(selected: selectedPeriod, onSelected: onPeriodSelected),
      ],
    );
  }
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({required this.selected, required this.onSelected});

  final AnalyticsPeriod selected;
  final void Function(AnalyticsPeriod) onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PeriodTab(
          label: '7 Days',
          isSelected: selected == AnalyticsPeriod.sevenDays,
          onTap: () => onSelected(AnalyticsPeriod.sevenDays),
        ),
        12.pw,
        _PeriodTab(
          label: '30 Days',
          isSelected: selected == AnalyticsPeriod.thirtyDays,
          onTap: () => onSelected(AnalyticsPeriod.thirtyDays),
        ),
        12.pw,
        _PeriodTab(
          label: 'All Time',
          isSelected: selected == AnalyticsPeriod.allTime,
          onTap: () => onSelected(AnalyticsPeriod.allTime),
        ),
      ],
    );
  }
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 15.w : 16.w,
          vertical: 9.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.listenerActiveTab
              : AppColors.listenerChipBg,
          borderRadius: 16.circular,
          border: isSelected
              ? null
              : Border.all(
                  color: AppColors.primaryWhite.withValues(alpha: 0.10),
                  width: 1.09,
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.hueBlack : AppColors.huegrey,
          ),
        ),
      ),
    );
  }
}
