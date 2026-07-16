import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'search_section_title.dart';

class SearchRecentSection extends StatelessWidget {
  const SearchRecentSection({super.key, required this.items, this.onItemTap});

  final List<String> items;
  final ValueChanged<String>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SearchSectionTitle(
          icon: Icons.access_time_rounded,
          title: 'Recent Searches',
          iconColor: AppColors.primaryWhite,
        ),
        12.ph,
        ...List.generate(
          items.length,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _RecentSearchItem(
              label: items[i],
              onTap: onItemTap != null ? () => onItemTap!(items[i]) : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentSearchItem extends StatelessWidget {
  const _RecentSearchItem({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.listenerChipBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.listenerChipBorder),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: AppColors.santagrey,
              size: 18.sp,
            ),
            12.pw,
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
