import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class ArtistCreatePostLinkDropdown extends StatelessWidget {
  const ArtistCreatePostLinkDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  final String hint;
  final List<String> items;
  final String? selected;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryWhite.withValues(alpha: 0.10),
          width: 1.09,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selected,
          hint: Text(
            hint,
            style: TextStyle(
              fontFamily: 'Roboto',
              color: AppColors.huegrey,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          dropdownColor: AppColors.listenerChipBg,
          borderRadius: BorderRadius.circular(16.r),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.huegrey,
            size: 20.sp,
          ),
          style: TextStyle(
            fontFamily: 'Roboto',
            color: AppColors.primaryWhite,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: selected == item
                                ? AppColors.listenerActiveTab
                                : AppColors.primaryWhite,
                            fontSize: 15.sp,
                            fontWeight: selected == item
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (selected == item)
                        Icon(
                          Icons.check_rounded,
                          color: AppColors.listenerActiveTab,
                          size: 18.sp,
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onSelect(value);
          },
        ),
      ),
    );
  }
}
