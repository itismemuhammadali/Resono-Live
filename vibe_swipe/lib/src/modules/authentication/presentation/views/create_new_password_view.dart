import '../../../../components/password_requirements_widget.dart';
import '../../../../core/utils/app_exports.dart';
import '../../../../components/primary_elevated_button.dart';
import '../../../../components/custom_textfield.dart';
import '../../../../components/auth_logo_header.dart';
import '../widgets/auth_back_button.dart';

class CreateNewPasswordView extends HookConsumerWidget {
  const CreateNewPasswordView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    useListenable(newPasswordController);

    void onUpdatePassword() {
      if (formKey.currentState!.validate()) {
        AppRouterGo.pushRemoveUntil(loginView);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/png/app_background_image.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    10.ph,
                    const AuthLogoHeader(),
                    20.ph,
                    const AuthBackButton(),
                    48.ph,
                    Center(
                      child: Image.asset(
                        "assets/icons/png/create_new_password_icn.png",
                      ),
                    ),
                    24.ph,
                    Center(
                      child: Text(
                        "Create New Password",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.primaryWhite,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    8.ph,
                    Center(
                      child: Text(
                        "Your new password must be different from previous passwords",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.santagrey,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    48.ph,
                    Text(
                      "New Password",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: AppColors.gray300,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    8.ph,
                    CustomTextField(
                      controller: newPasswordController,
                      hintText: "Enter new password",
                      isPrefix: true,
                      prefixWidget: Padding(
                        padding: EdgeInsets.all(2.w),
                        child: Image.asset(
                          'assets/icons/png/lock-icon.png',
                          width: 20.w,
                        height: 20.w,
                        ),
                      ),
                      isObscure: true,
                      isSuffix: true,
                      fillColor: AppColors.listenerChipBg,
                      enableBorderColor: AppColors.listenerChipBorder,
                      focusedBorderColor: AppColors.listenerYellow,
                      cursorColor: AppColors.primaryWhite,
                      textStyle: TextStyle(
                        fontFamily: 'Roboto',
                        color: AppColors.primaryWhite,
                        fontSize: 14.sp,
                      ),
                      hintTextStyle: TextStyle(
                        fontFamily: 'Roboto',
                        color: AppColors.gray500,
                        fontSize: 14.sp,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      validator: AppValidators.validateNewPassword,
                    ),
                    12.ph,
                    PasswordRequirementsWidget(
                      password: newPasswordController.text,
                    ),
                    20.ph,
                    Text(
                      "Confirm New Password",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: AppColors.gray300,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    8.ph,
                    CustomTextField(
                      controller: confirmPasswordController,
                      hintText: "Re-enter new password",
                      isPrefix: true,
                      prefixWidget: Padding(
                        padding: EdgeInsets.all(2.w),
                        child: Image.asset(
                          'assets/icons/png/lock-icon.png',
                          width: 20.w,
                        height: 20.w,
                        ),
                      ),
                      isObscure: true,
                      isSuffix: true,
                      isLast: true,
                      fillColor: AppColors.listenerChipBg,
                      enableBorderColor: AppColors.listenerChipBorder,
                      focusedBorderColor: AppColors.listenerYellow,
                      cursorColor: AppColors.primaryWhite,
                      textStyle: TextStyle(
                        fontFamily: 'Roboto',
                        color: AppColors.primaryWhite,
                        fontSize: 14.sp,
                      ),
                      hintTextStyle: TextStyle(
                        fontFamily: 'Roboto',
                        color: AppColors.gray500,
                        fontSize: 14.sp,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      validator: (value) =>
                          AppValidators.confirmPass(value, newPasswordController),
                    ),
                    32.ph,
                    PrimaryElevatedButton(
                      onTap: onUpdatePassword,
                      text: "Update Password",
                      backgroundColor: AppColors.listenerYellow,
                      textColor: AppColors.primaryblack,
                      radius: 12,
                    ),
                    24.ph,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
