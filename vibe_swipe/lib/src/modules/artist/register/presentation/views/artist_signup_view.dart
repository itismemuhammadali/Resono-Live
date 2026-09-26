import '../../../../../components/password_requirements_widget.dart';
import '../../../../../core/utils/app_exports.dart';
import '../../../../../components/primary_elevated_button.dart';
import '../../../../authentication/presentation/controllers/authentication_controller.dart';
import '../../../../authentication/presentation/widgets/email_verification_dialog.dart';
import '../../../../authentication/presentation/widgets/auth_back_button.dart';
import '../../../../authentication/presentation/widgets/social_auth_buttons.dart';
import '../widgets/artist_signup_header.dart';
import '../widgets/artist_labeled_field.dart';
import '../widgets/artist_signin_footer.dart';

class ArtistSignupView extends HookConsumerWidget {
  const ArtistSignupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    useListenable(passwordController);
    final authController = ref.watch(authControllerProvider);
    final agreedToTerms = useState(false);
    final termsError = useState(false);

    void onContinue() async {
      if (!agreedToTerms.value) {
        termsError.value = true;
        return;
      }
      termsError.value = false;
      if (formKey.currentState!.validate()) {
        final success = await ref.read(authControllerProvider).signUp(
              name: nameController.text.trim(),
              email: emailController.text.trim(),
              password: passwordController.text,
            );
        if (success && context.mounted) {
          EmailVerificationDialog.show(
            context,
            email: emailController.text.trim(),
            targetRoute: artistSetupView,
            isSignUp: true,
          );
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
                  const AuthBackButton(),
                  28.ph,
                  const ArtistSignupHeader(),
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
                  ArtistLabeledField(
                    label: "Artist Name",
                    hintText: "Artist Name",
                    controller: nameController,
                    prefixWidget: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Image.asset(
                        'assets/icons/png/user-icon.png',
                        width: 20.w,
                        height: 20.w,
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => AppValidators.validateEmpty(
                      value,
                      'Artist name is required',
                    ),
                  ),
                  24.ph,
                  ArtistLabeledField(
                    label: "Email/Phone",
                    hintText: "artist@example.com",
                    controller: emailController,
                    prefixWidget: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Image.asset(
                        'assets/icons/png/email-icon.png',
                        width: 20.w,
                        height: 20.w,
                      ),
                    ),
                    textInputType: TextInputType.emailAddress,
                    validator: AppValidators.validateEmailOrPhone,
                  ),
                  24.ph,
                  ArtistLabeledField(
                    label: "New Password",
                    hintText: "Enter new password",
                    controller: passwordController,
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
                    validator: AppValidators.validateNewPassword,
                  ),
                  12.ph,
                  PasswordRequirementsWidget(
                    password: passwordController.text,
                  ),
                  20.ph,
                  ArtistLabeledField(
                    label: "Confirm Password",
                    hintText: "Confirm new password",
                    controller: confirmPasswordController,
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
                    validator: (value) =>
                        AppValidators.confirmPass(value, passwordController),
                  ),
                  24.ph,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: Checkbox(
                          value: agreedToTerms.value,
                          onChanged: (val) {
                            agreedToTerms.value = val ?? false;
                            if (agreedToTerms.value) termsError.value = false;
                          },
                          activeColor: AppColors.listenerYellow,
                          checkColor: AppColors.primaryblack,
                          side: BorderSide(
                            color: termsError.value
                                ? Colors.redAccent
                                : AppColors.listenerChipBorder,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      10.pw,
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            agreedToTerms.value = !agreedToTerms.value;
                            if (agreedToTerms.value) termsError.value = false;
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12.sp,
                                color: AppColors.santagrey,
                              ),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => AppRouterGo.push(
                                      termsAndPoliciesView,
                                      extra: {'sectionId': 'terms', 'isArtist': true},
                                    ),
                                    child: Text(
                                      'Terms of Use (EULA)',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.listenerYellow,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => AppRouterGo.push(
                                      termsAndPoliciesView,
                                      extra: {'sectionId': 'privacy', 'isArtist': true},
                                    ),
                                    child: Text(
                                      'Privacy Policy',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.listenerYellow,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (termsError.value) ...[
                    6.ph,
                    Padding(
                      padding: EdgeInsets.only(left: 34.w),
                      child: Text(
                        'You must accept the Creator Terms & Policies to continue',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 11.sp,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                  24.ph,
                  PrimaryElevatedButton(
                    onTap: onContinue,
                    text: authController.isLoading ? "Creating Account..." : "Continue and Setup",
                    loader: authController.isLoading,
                    backgroundColor: AppColors.listenerYellow,
                    textColor: AppColors.primaryblack,
                    radius: 12,
                  ),
                  24.ph,
                  SocialAuthButtons(
                    isSignUp: true,
                    onAuthStarted: () {
                      authController.clearError();
                    },
                  ),
                  24.ph,
                  const ArtistSigninFooter(),
                  24.ph,
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
