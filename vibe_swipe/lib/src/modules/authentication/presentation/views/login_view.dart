import '../../../../core/utils/app_exports.dart';
import '../../presentation/controllers/authentication_controller.dart';
import '../../presentation/widgets/email_verification_dialog.dart';
import '../../presentation/widgets/social_auth_buttons.dart';
import '../../../../components/primary_elevated_button.dart';
import '../../../../components/custom_textfield.dart';
import '../../../../components/auth_logo_header.dart';
import '../../presentation/widgets/auth_back_button.dart';

class LoginView extends HookConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final authController = ref.watch(authControllerProvider);
    final selectedRole = useState<UserRole>(AppConfig.userRole);

    void onSignIn() async {
      if (formKey.currentState!.validate()) {
        final controller = ref.read(authControllerProvider);
        final success = await controller.signIn(
              email: emailController.text.trim(),
              password: passwordController.text,
            );
        if (success && context.mounted) {
          final uid = locator<FirebaseAuthService>().getUid();
          final isCompleted = uid != null
              ? await controller.isProfileCompleted(uid)
              : false;

          final effectiveRole = AppConfig.userRole;
          final setupTarget = effectiveRole == UserRole.artist
              ? artistSetupView
              : profileSetupView;
          final dashboardTarget = effectiveRole == UserRole.artist
              ? artistDashboardView
              : listenerDashboardView;

          final target = isCompleted ? dashboardTarget : setupTarget;

          if (!context.mounted) return;

          if (!controller.isEmailVerified) {
            EmailVerificationDialog.show(
              context,
              email: emailController.text.trim(),
              targetRoute: target,
              isSignUp: false,
            );
          } else {
            AppRouterGo.pushReplacement(target);
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/png/app_background_image.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 48.h,
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                  10.ph,
                  AuthBackButton(onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      AppRouterGo.pushReplacement(modeSelectionView);
                    }
                  }),
                  28.ph,
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
                  const Spacer(),
                  24.ph,
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
                      selectedRole.value == UserRole.artist
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
                  24.ph,
                  const SocialAuthButtons(),
                  16.ph,
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        final newRole = selectedRole.value == UserRole.artist
                            ? UserRole.listener
                            : UserRole.artist;
                        selectedRole.value = newRole;
                        AppConfig.userRole = newRole;
                        authController.clearError();
                      },
                      child: Text.rich(
                        TextSpan(
                          text: selectedRole.value == UserRole.artist
                              ? "Not an Artist? "
                              : "Are you an Artist? ",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 13.sp,
                            color: AppColors.santagrey,
                          ),
                          children: [
                            TextSpan(
                              text: "Switch here",
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 13.sp,
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
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text.rich(
                        TextSpan(
                          text: "By signing in or registering, you agree to our ",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12.sp,
                            color: AppColors.santagrey,
                          ),
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: GestureDetector(
                                onTap: () => AppRouterGo.push(
                                  termsAndPoliciesView,
                                  extra: {'sectionId': 'terms', 'isArtist': selectedRole.value == UserRole.artist},
                                ),
                                child: Text(
                                  "Terms of Use (EULA)",
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12.sp,
                                    color: AppColors.listenerYellow,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.listenerYellow,
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(
                              text: " and ",
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12.sp,
                                color: AppColors.santagrey,
                              ),
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: GestureDetector(
                                onTap: () => AppRouterGo.push(
                                  termsAndPoliciesView,
                                  extra: {'sectionId': 'privacy', 'isArtist': selectedRole.value == UserRole.artist},
                                ),
                                child: Text(
                                  "Privacy Policy",
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12.sp,
                                    color: AppColors.listenerYellow,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.listenerYellow,
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(
                              text: ".",
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12.sp,
                                color: AppColors.santagrey,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  16.ph,
                ],
              ),
            ),
          ),
        ),
      );
    },
  ),
),
),
),
);
  }
}
