import 'package:flutter/cupertino.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class PublicProfileTile extends StatelessWidget {
  const PublicProfileTile({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryWhite.withValues(alpha: 0.10),
          width: 1.09,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Public Profile',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryWhite,
                    fontFamily: 'Roboto',
                  ),
                ),
                4.ph,
                Text(
                  'Make your profile visible to everyone',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.huegrey,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.listenerActiveTab,
            thumbColor: AppColors.black,
          ),
        ],
      ),
    );
  }
}
