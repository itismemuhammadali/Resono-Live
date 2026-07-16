import 'package:vibe_swipe/src/components/custom_textfield.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class CommunityDetailSearchBar extends StatelessWidget {
  const CommunityDetailSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hintText: 'Search discussions...',
      isLast: true,
      isPrefix: true,
      prefixWidget: Icon(
        Icons.search,
        color: AppColors.coolGray,
        size: 20.sp,
      ),
      fillColor: AppColors.listenerChipBg,
      enableBorderColor: AppColors.listenerBackButtonBorder,
      focusedBorderColor: AppColors.listenerBackButtonBorder,
      cursorColor: AppColors.listenerYellow,
      fieldBorderRadius: 16,
      borderWidth: 1.09,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
      hintTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.coolGray,
      ),
      textStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryWhite,
      ),
    );
  }
}
