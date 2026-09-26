import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/app_exports.dart';
import '../../../../components/primary_elevated_button.dart';
import '../controllers/authentication_controller.dart';
import '../../../listner/register/presentation/controllers/listener_register_controller.dart';
import '../../../artist/register/presentation/controllers/artist_register_controller.dart';

class SocialAuthButtons extends ConsumerWidget {
  final VoidCallback? onAuthStarted;

  const SocialAuthButtons({
    super.key,
    this.onAuthStarted,
  });

  void _showAppleIosOnlyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.listenerDashboardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.listenerChipBorder.withValues(alpha: 0.3),
                ),
                child: Icon(
                  Icons.apple,
                  size: 36.sp,
                  color: AppColors.primaryWhite,
                ),
              ),
              16.ph,
              Text(
                "Apple Sign-In is iOS Only",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryWhite,
                ),
                textAlign: TextAlign.center,
              ),
              12.ph,
              Text(
                "Apple Sign-In is designed for Apple devices. On Android, please sign in using Google or your Email address.",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14.sp,
                  color: AppColors.santagrey,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              24.ph,
              PrimaryElevatedButton(
                onTap: () => Navigator.pop(ctx),
                text: "Got It",
                backgroundColor: AppColors.listenerYellow,
                textColor: AppColors.primaryblack,
                radius: 12,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handlePostAuthNavigation(BuildContext context, WidgetRef ref) async {
    final uid = locator<FirebaseAuthService>().getUid();
    final authCtrl = ref.read(authControllerProvider);
    final isCompleted = uid != null ? await authCtrl.isProfileCompleted(uid) : false;

    if (!context.mounted) return;

    if (isCompleted) {
      final target = AppConfig.userRole == UserRole.artist
          ? artistDashboardView
          : listenerDashboardView;
      AppRouterGo.pushReplacement(target);
    } else {
      if (AppConfig.userRole == UserRole.artist) {
        final user = FirebaseAuth.instance.currentUser;
        final name = user?.displayName ?? locator<FirebaseAuthService>().lastAppleFullName;
        if (name != null && name.isNotEmpty) {
          ref.read(artistRegisterControllerProvider).setArtistName(name);
        }
        AppRouterGo.pushReplacement(artistSetupView);
      } else {
        final user = FirebaseAuth.instance.currentUser;
        final name = user?.displayName ?? locator<FirebaseAuthService>().lastAppleFullName;
        if (name != null && name.isNotEmpty) {
          ref.read(listenerRegisterControllerProvider).setUsername(name);
        }
        AppRouterGo.pushReplacement(profileSetupView);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        24.ph,
        Row(
          children: [
            Expanded(
              child: PrimaryElevatedButton(
                enabled: !authController.isLoading,
                onTap: () async {
                  onAuthStarted?.call();
                  authController.clearError();
                  try {
                    final success = await ref.read(authControllerProvider).signInWithGoogle();
                    if (success && context.mounted) {
                      await _handlePostAuthNavigation(context, ref);
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
                text: "Google",
                backgroundColor: AppColors.transparent,
                textColor: AppColors.primaryWhite,
                radius: 12,
                buttonStyle: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(
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
                enabled: !authController.isLoading,
                onTap: () async {
                  onAuthStarted?.call();
                  authController.clearError();
                  if (Platform.isAndroid) {
                    _showAppleIosOnlyBottomSheet(context);
                    return;
                  }
                  try {
                    final success = await ref.read(authControllerProvider).signInWithApple();
                    if (success && context.mounted) {
                      await _handlePostAuthNavigation(context, ref);
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
                text: "Apple",
                backgroundColor: AppColors.transparent,
                textColor: AppColors.primaryWhite,
                radius: 12,
                buttonStyle: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(
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
      ],
    );
  }
}
