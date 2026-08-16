import 'package:flutter/cupertino.dart';
import '../../../../core/utils/app_exports.dart';
import '../../presentation/controllers/authentication_controller.dart';
import '../../../../components/primary_elevated_button.dart';
import '../../../../components/custom_textfield.dart';
import '../../../../components/auth_logo_header.dart';
import '../widgets/auth_back_button.dart';

class ForgotPasswordView extends HookConsumerWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final authController = ref.watch(authControllerProvider);
    final emailSent = useState(false);

    void onSendResetLink() async {
      if (formKey.currentState!.validate()) {
        await ref.read(authControllerProvider).sendPasswordReset(
              emailController.text.trim(),
            );
        if (ref.read(authControllerProvider).errorMessage == null) {
          emailSent.value = true;
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/png/app_background_image.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
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
                    const AuthLogoHeader(),
                    20.ph,
                    const AuthBackButton(),
                    40.ph,
                    Center(
                      child: Image.asset(
                        "assets/icons/png/forgot_password_icn.png",
                      ),
                    ),
                    24.ph,
                    Center(
                      child: Text(
                        emailSent.value ? "Email Sent!" : "Check Your Email",
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
                        emailSent.value
                            ? "We've sent a password reset link to:"
                            : "We'll send a password reset link to:",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.santagrey,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (emailSent.value) ...[
                      4.ph,
                      Center(
                        child: Text(
                          emailController.text.trim(),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: AppColors.santagrey,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
                    if (!emailSent.value) ...[
                      Text(
                        "Enter Email",
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
                        hintText: "Enter your register mail",
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
                        validator: AppValidators.validateEmail,
                      ),
                      24.ph,
                      PrimaryElevatedButton(
                        onTap: onSendResetLink,
                        text: authController.isLoading ? "Sending..." : "Send Reset Link",
                        loader: authController.isLoading,
                        backgroundColor: AppColors.listenerYellow,
                        textColor: AppColors.primaryblack,
                        radius: 12,
                      ),
                    ],
                    24.ph,
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.listenerChipBg,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.listenerChipBorder,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "What's next?",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: AppColors.primaryWhite,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          8.ph,
                          Text(
                            "Click the link in the email to create a new password. The link will expire in 24 hours.",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: AppColors.santagrey,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    32.ph,
                    if (emailSent.value)
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            authController.clearError();
                            emailSent.value = false;
                            emailController.clear();
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontFamily: 'Roboto', fontSize: 14.sp),
                              children: [
                                const TextSpan(
                                  text: "Wrong email?  ",
                                  style: TextStyle(
                                    color: AppColors.santagrey,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const TextSpan(
                                  text: "Try Again",
                                  style: TextStyle(
                                    color: AppColors.listenerYellow,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            authController.clearError();
                            onSendResetLink();
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontFamily: 'Roboto', fontSize: 14.sp),
                              children: [
                                const TextSpan(
                                  text: "Didn't receive the email?  ",
                                  style: TextStyle(
                                    color: AppColors.santagrey,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const TextSpan(
                                  text: "Resend",
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
        );
      },
    ),
  ),
],
),
);
  }
}
