import 'package:vibe_swipe/src/components/custom_textfield.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class SearchInputBar extends StatelessWidget {
  const SearchInputBar({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: 'Search artists or usernames',
      isPrefix: true,
      prefixWidget: Icon(Icons.search, color: AppColors.santagrey, size: 20.sp),
      onChanged: onChanged,
      fillColor: AppColors.listenerChipBg,
      enableBorderColor: AppColors.listenerChipBorder,
      focusedBorderColor: AppColors.listenerChipBorder,
      cursorColor: AppColors.primaryWhite,
      textStyle: TextStyle(fontSize: 14.sp, color: AppColors.primaryWhite),
      hintTextStyle: TextStyle(fontSize: 14.sp, color: AppColors.santagrey),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      isLast: true,
    );
  }
}
