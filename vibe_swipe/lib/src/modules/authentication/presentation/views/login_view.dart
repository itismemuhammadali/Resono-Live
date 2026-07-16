import 'package:flutter/cupertino.dart';
import '../../../../core/utils/app_exports.dart';
import '../../presentation/controllers/authentication_controller.dart';
import '../../../../components/primary_elevated_button.dart';
import '../../../../components/custom_textfield.dart';
import '../../../../components/auth_logo_header.dart';

class LoginView extends HookConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final authController = ref.watch(authControllerProvider);

    void onSignIn() async {
      if (formKey.currentState!.validate()) {
        final success = await ref.read(authControllerProvider).signIn(
              email: emailController.text.trim(),
              password: passwordController.text,
            );
        if (success && context.mounted) {
          AppConfig.userRole == UserRole.artist
              ? AppRouterGo.pushReplacement(artistDashboardView)
              : AppRouterGo.pushReplacement(listenerDashboardView);
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
                    "Welcome Back",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: AppColors.primaryWhite,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  8.ph,
                  Text(
                    "Sign in to continue tracking",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: AppColors.santagrey,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  32.ph,
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
                    hintText: "Enter your email",
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
                  16.ph,
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
                    validator: AppValidators.validatePass,
                  ),
                  16.ph,
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        AppRouterGo.push(forgotPasswordView);
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.listenerYellow,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  177.ph,
                  PrimaryElevatedButton(
                    onTap: onSignIn,
                    text: authController.isLoading ? "Signing in..." : "Sign in",
                    loader: authController.isLoading,
                    backgroundColor: AppColors.listenerYellow,
                    textColor: AppColors.primaryblack,
                    radius: 12,
                  ),
                  16.ph,
                  PrimaryElevatedButton(
                    onTap: () {
                      authController.clearError();
                      AppConfig.userRole == UserRole.artist
                          ? AppRouterGo.push(artistSignupView)
                          : AppRouterGo.push(signupView);
                    },
                    text: "Create Account",
                    backgroundColor: AppColors.transparent,
                    textColor: AppColors.primaryWhite,
                    radius: 12,
                    buttonStyle: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: const BorderSide(
                          color: AppColors.listenerBackButtonBorder,
                        ),
                      ),
                      elevation: 0,
                    ),
                  ),
                  32.ph,
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.listenerChipBorder,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          "Or continue with",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: AppColors.santagrey,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.listenerChipBorder,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  32.ph,
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryElevatedButton(
                          onTap: () {},
                          text: "Google",
                          backgroundColor: AppColors.transparent,
                          textColor: AppColors.primaryWhite,
                          radius: 12,
                          buttonStyle: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: const BorderSide(
                                color: AppColors.listenerBackButtonBorder,
                              ),
                            ),
                            elevation: 0,
                          ),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: AppColors.primaryWhite,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      16.pw,
                      Expanded(
                        child: PrimaryElevatedButton(
                          onTap: () {},
                          text: "Apple",
                          backgroundColor: AppColors.transparent,
                          textColor: AppColors.primaryWhite,
                          radius: 12,
                          buttonStyle: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: const BorderSide(
                                color: AppColors.listenerBackButtonBorder,
                              ),
                            ),
                            elevation: 0,
                          ),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: AppColors.primaryWhite,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  24.ph,
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        authController.clearError();
                        AppRouterGo.pushReplacement('/');
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14.sp,
                          ),
                          children: [
                            TextSpan(
                              text: "Switch Mode?  ",
                              style: TextStyle(
                                color: AppColors.santagrey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: "Listener / Artist",
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
                  16.ph,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
