import 'package:flutter/cupertino.dart';
import '../../../../../core/utils/app_exports.dart';
import '../../../../../components/primary_elevated_button.dart';
import '../../../../../components/custom_textfield.dart';
import '../../../../../components/auth_logo_header.dart';
import '../../../../authentication/presentation/controllers/authentication_controller.dart';

class ListnerSignupView extends HookConsumerWidget {
  const ListnerSignupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final fullNameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final authController = ref.watch(authControllerProvider);

    void onCreateAccount() async {
      if (formKey.currentState!.validate()) {
        final success = await ref.read(authControllerProvider).signUp(
              name: fullNameController.text.trim(),
              email: emailController.text.trim(),
              password: passwordController.text,
            );
        if (success && context.mounted) {
          AppRouterGo.push(profileSetupView);
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/png/app_background_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  10.ph,
                  const AuthLogoHeader(),
                  28.ph,
                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: AppColors.primaryWhite,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  8.ph,
                  Text(
                    "Join VibeSwipe and start discovering",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: AppColors.santagrey,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  40.ph,
                  if (authController.errorMessage != null) ...[
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        authController.errorMessage!,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: Colors.red[300],
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    16.ph,
                  ],
                  Text(
                    "Full Name",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: AppColors.gray300,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  8.ph,
                  CustomTextField(
                    controller: fullNameController,
                    hintText: "Enter your full name",
                    isPrefix: true,
                    prefixWidget: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Image.asset(
                        'assets/icons/png/user-icon.png',
                        width: 20.w,
                        height: 20.w,
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
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
                    validator: (value) => AppValidators.validateEmpty(
                      value,
                      'Full name is required',
                    ),
                  ),
                  24.ph,
                  Text(
                    "Email or Phone",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: AppColors.gray300,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  8.ph,
                  CustomTextField(
                    controller: emailController,
                    hintText: "Enter your email or phone",
                    isPrefix: true,
                    prefixWidget: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Image.asset(
                        'assets/icons/png/email-icon.png',
                        width: 20.w,
                        height: 20.w,
                      ),
                    ),
                    textInputType: TextInputType.emailAddress,
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
                    validator: AppValidators.validateEmailOrPhone,
                  ),
                  24.ph,
                  Text(
                    "Password",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: AppColors.gray300,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  8.ph,
                  CustomTextField(
                    controller: passwordController,
                    hintText: "Enter your password",
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
                    validator: AppValidators.validatePass,
                  ),
                  24.ph,
                  Text(
                    "Confirm Password",
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
                    hintText: "Confirm your password",
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
                        AppValidators.confirmPass(value, passwordController),
                  ),
                  172.ph,
                  PrimaryElevatedButton(
                    onTap: onCreateAccount,
                    text: authController.isLoading ? "Creating Account..." : "Create Account",
                    loader: authController.isLoading,
                    backgroundColor: AppColors.listenerYellow,
                    textColor: AppColors.primaryblack,
                    radius: 12,
                  ),
                  24.ph,
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        authController.clearError();
                        AppRouterGo.back();
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14.sp,
                          ),
                          children: const [
                            TextSpan(
                              text: "Already have an account?  ",
                              style: TextStyle(
                                color: AppColors.santagrey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: "Sign In",
                              style: TextStyle(
                                color: AppColors.listenerYellow,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  24.ph,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
