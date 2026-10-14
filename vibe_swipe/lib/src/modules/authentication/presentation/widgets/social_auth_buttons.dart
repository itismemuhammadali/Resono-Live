import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/utils/app_exports.dart';
import '../../../../components/primary_elevated_button.dart';
import '../controllers/authentication_controller.dart';
import '../../../listner/register/presentation/controllers/listener_register_controller.dart';
import '../../../artist/register/presentation/controllers/artist_register_controller.dart';

class SocialAuthButtons extends ConsumerWidget {
  final VoidCallback? onAuthStarted;
  final bool isSignUp;

  const SocialAuthButtons({
    super.key,
    this.onAuthStarted,
    this.isSignUp = false,
  });


  Future<void> _handlePostAuthNavigation(BuildContext context, WidgetRef ref) async {
    final uid = locator<FirebaseAuthService>().getUid();
    final authCtrl = ref.read(authControllerProvider);
    final isCompleted = uid != null ? await authCtrl.isProfileCompleted(uid) : false;

    if (!context.mounted) return;

    // When signing up, ALWAYS guide the user through profile onboarding.
    // Also, if logging in with an incomplete profile, route to onboarding as well.
    if (isSignUp || !isCompleted) {
      final user = FirebaseAuth.instance.currentUser;
      final appleName = locator<FirebaseAuthService>().lastAppleFullName;
      final googleName = user?.displayName;
      final emailFallback = (user?.email != null && user!.email!.isNotEmpty)
          ? user.email!.split('@').first
          : '';
      final resolvedName = (appleName != null && appleName.trim().isNotEmpty)
          ? appleName.trim()
          : (googleName != null && googleName.trim().isNotEmpty)
              ? googleName.trim()
              : emailFallback;

      if (AppConfig.userRole == UserRole.artist) {
        if (resolvedName.isNotEmpty) {
          ref.read(artistRegisterControllerProvider).setArtistName(resolvedName);
        }
        AppRouterGo.pushReplacement(artistSetupView);
      } else {
        if (resolvedName.isNotEmpty) {
          ref.read(listenerRegisterControllerProvider).setUsername(resolvedName);
        }
        AppRouterGo.pushReplacement(profileSetupView);
      }
      return;
    }

    // User logging in from Login screen with profile already completed:
    final target = AppConfig.userRole == UserRole.artist
        ? artistDashboardView
        : listenerDashboardView;
    AppRouterGo.pushReplacement(target);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
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
            const Expanded(
              child: Divider(
                color: AppColors.listenerChipBorder,
                thickness: 1,
              ),
            ),
          ],
        ),
        24.ph,
        Builder(
          builder: (context) {
            final showApple = !kIsWeb && Platform.isIOS;
            final googleButton = PrimaryElevatedButton(
              enabled: !authController.isLoading,
              onTap: () async {
                onAuthStarted?.call();
                authController.clearError();
                try {
                  final success = await ref.read(authControllerProvider).signInWithGoogle(isSignUp: isSignUp);
                  if (success && context.mounted) {
                    await _handlePostAuthNavigation(context, ref);
                  } else if (!success && context.mounted) {
                    final error = ref.read(authControllerProvider).errorMessage;
                    if (error != null && error.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error),
                          backgroundColor: Colors.red.shade800,
                        ),
                      );
                    }
                  }
                } on PlatformException catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Google Sign-In failed: ${e.message ?? 'Please try again.'}'),
                        backgroundColor: Colors.red.shade800,
                      ),
                    );
                  }
                } catch (_) {
                  // Auth controller already sets errorMessage for FirebaseAuthExceptions
                }
              },
              text: isSignUp ? "Sign up with Google" : "Sign in with Google",
              backgroundColor: AppColors.transparent,
              textColor: AppColors.primaryWhite,
              radius: 12,
              height: 48.h,
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
            );

            if (!showApple) {
              return SizedBox(
                width: double.infinity,
                child: googleButton,
              );
            }

            final appleButton = SizedBox(
              height: 48.h,
              child: SignInWithAppleButton(
                onPressed: () async {
                  if (authController.isLoading) return;
                  onAuthStarted?.call();
                  authController.clearError();
                  try {
                    final success = await ref.read(authControllerProvider).signInWithApple(isSignUp: isSignUp);
                    if (success && context.mounted) {
                      await _handlePostAuthNavigation(context, ref);
                    } else if (!success && context.mounted) {
                      final error = ref.read(authControllerProvider).errorMessage;
                      if (error != null && error.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: Colors.red.shade800,
                          ),
                        );
                      }
                    }
                  } on PlatformException catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Apple Sign-In failed: ${e.message ?? 'Please try again.'}'),
                          backgroundColor: Colors.red.shade800,
                        ),
                      );
                    }
                  } catch (_) {
                    // Auth controller already sets errorMessage for exceptions
                  }
                },
                text: isSignUp ? 'Sign up with Apple' : 'Sign in with Apple',
                height: 48.h,
                style: SignInWithAppleButtonStyle.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            );

            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: appleButton,
                ),
                12.ph,
                SizedBox(
                  width: double.infinity,
                  child: googleButton,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
