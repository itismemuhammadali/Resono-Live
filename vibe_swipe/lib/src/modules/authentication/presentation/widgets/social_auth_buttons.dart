import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/utils/app_exports.dart';
import '../controllers/authentication_controller.dart';
import '../../../listner/register/presentation/controllers/listener_register_controller.dart';
import '../../../artist/register/presentation/controllers/artist_register_controller.dart';

const String _googleLogoSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
  <path fill="none" d="M0 0h48v48H0z"/>
</svg>
''';

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
            final googleButton = SizedBox(
              height: 44,
              child: CupertinoButton(
                borderRadius: BorderRadius.circular(12.r),
                padding: EdgeInsets.zero,
                color: Colors.white,
                onPressed: authController.isLoading
                    ? null
                    : () async {
                        onAuthStarted?.call();
                        authController.clearError();
                        try {
                          final success = await ref
                              .read(authControllerProvider)
                              .signInWithGoogle(isSignUp: isSignUp);
                          if (success && context.mounted) {
                            await _handlePostAuthNavigation(context, ref);
                          } else if (!success && context.mounted) {
                            final error =
                                ref.read(authControllerProvider).errorMessage;
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
                                content: Text(
                                    'Google Sign-In failed: ${e.message ?? 'Please try again.'}'),
                                backgroundColor: Colors.red.shade800,
                              ),
                            );
                          }
                        } catch (_) {
                          // Auth controller already sets errorMessage for FirebaseAuthExceptions
                        }
                      },
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 30,
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Center(
                          child: SvgPicture.string(
                            _googleLogoSvg,
                            width: 18.92 * (25 / 31),
                            height: 18.92,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          isSignUp ? "Sign up with Google" : "Sign in with Google",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            inherit: false,
                            fontSize: 18.92,
                            color: Colors.black,
                            fontFamily: '.SF Pro Text',
                            letterSpacing: -0.41,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            if (!showApple) {
              return SizedBox(
                width: double.infinity,
                child: googleButton,
              );
            }

            final appleButton = SizedBox(
              height: 44,
              child: SignInWithAppleButton(
                onPressed: () async {
                  if (authController.isLoading) return;
                  onAuthStarted?.call();
                  authController.clearError();
                  try {
                    final success = await ref
                        .read(authControllerProvider)
                        .signInWithApple(isSignUp: isSignUp);
                    if (success && context.mounted) {
                      await _handlePostAuthNavigation(context, ref);
                    } else if (!success && context.mounted) {
                      final error =
                          ref.read(authControllerProvider).errorMessage;
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
                          content: Text(
                              'Apple Sign-In failed: ${e.message ?? 'Please try again.'}'),
                          backgroundColor: Colors.red.shade800,
                        ),
                      );
                    }
                  } catch (_) {
                    // Auth controller already sets errorMessage for exceptions
                  }
                },
                text: isSignUp ? 'Sign up with Apple' : 'Sign in with Apple',
                height: 44,
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
