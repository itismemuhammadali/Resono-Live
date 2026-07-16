import 'package:flutter/cupertino.dart';
import '../../../../../core/utils/app_exports.dart';

class ArtistPublicProfileToggle extends StatelessWidget {
  const ArtistPublicProfileToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border(
          top: BorderSide(
            color: AppColors.primaryWhite.withValues(alpha: 0.10),
            width: 1.09,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Public Profile",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: AppColors.primaryWhite,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                4.ph,
                Text(
                  "Make your profile visible to everyone",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: AppColors.santagrey,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.listenerYellow,
            thumbColor: AppColors.primaryWhite,
          ),
        ],
      ),
    );
  }
}
