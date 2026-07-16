import '../../../../core/utils/app_exports.dart';

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRouterGo.back(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back, color: AppColors.primaryWhite, size: 16.sp),
          6.pw,
          Text(
            "Back",
            style: TextStyle(
              fontFamily: 'Roboto',
              color: AppColors.primaryWhite,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
