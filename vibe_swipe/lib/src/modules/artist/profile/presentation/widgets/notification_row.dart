import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class NotificationRow extends StatelessWidget {
  const NotificationRow({
    super.key,
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.showDivider,
  });

  final String asset;
  final String title;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Image.asset(asset),
              12.pw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryWhite,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    3.ph,
                    Text(
                      subtitle,
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
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: AppColors.black,
                activeTrackColor: AppColors.listenerYellow,
                inactiveThumbColor: AppColors.primaryWhite,
                inactiveTrackColor: AppColors.listenerBackButtonBorder,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.primaryWhite.withValues(alpha: 0.06),
          ),
      ],
    );
  }
}
