import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class CommunitySectionTitle extends StatelessWidget {
  const CommunitySectionTitle({
    super.key,
    this.icon,
    this.asset,
    required this.title,
  }) : assert(icon != null || asset != null, 'Provide either icon or asset');

  final IconData? icon;
  final String? asset;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (asset != null)
          Image.asset(
            asset!,
            color: AppColors.listenerYellow,
            width: 20.w,
            height: 20.h,
          )
        else
          Icon(icon, color: AppColors.listenerYellow, size: 20.sp),
        10.pw,
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryWhite,
          ),
        ),
      ],
    );
  }
}
