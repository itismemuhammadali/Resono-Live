import '../core/utils/app_exports.dart';

class PasswordRequirementsWidget extends StatelessWidget {
  final String password;

  const PasswordRequirementsWidget({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final hasMinLength = AppValidators.hasMinLength(password);
    final hasUppercase = AppValidators.hasUppercase(password);
    final hasLowercase = AppValidators.hasLowercase(password);
    final hasDigit = AppValidators.hasDigit(password);
    final hasSpecial = AppValidators.hasSpecialChar(password);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.listenerChipBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Password must contain:",
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.santagrey,
            ),
          ),
          8.ph,
          Wrap(
            spacing: 12.w,
            runSpacing: 6.h,
            children: [
              _buildRule("8+ characters", hasMinLength),
              _buildRule("1 uppercase (A-Z)", hasUppercase),
              _buildRule("1 lowercase (a-z)", hasLowercase),
              _buildRule("1 number (0-9)", hasDigit),
              _buildRule("1 special symbol", hasSpecial),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRule(String text, bool satisfied) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          satisfied ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 13.sp,
          color: satisfied ? Colors.greenAccent : AppColors.gray500,
        ),
        5.pw,
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 11.sp,
            color: satisfied ? AppColors.primaryWhite : AppColors.santagrey,
            fontWeight: satisfied ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
