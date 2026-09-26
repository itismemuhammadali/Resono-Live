import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/utils/app_exports.dart';
import '../../../../../components/primary_elevated_button.dart';
import '../../../../../components/custom_textfield.dart';
import '../../../../../components/auth_logo_header.dart';
import '../../../../authentication/presentation/widgets/auth_back_button.dart';
import '../../../../authentication/presentation/widgets/profile_setup_exit_dialog.dart';
import '../../../../authentication/presentation/controllers/authentication_controller.dart';
import '../controllers/listener_register_controller.dart';
import 'package:vibe_swipe/src/components/auth_step_progress.dart';

class ProfileSetupView extends HookConsumerWidget {
  const ProfileSetupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(listenerRegisterControllerProvider);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final usernameController = useTextEditingController();

    useEffect(() {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final appleName = locator<FirebaseAuthService>().lastAppleFullName;
        final googleName = user.displayName;
        final existingCtrlName = controller.username;
        String defaultUsername = existingCtrlName.isNotEmpty
            ? existingCtrlName
            : (appleName != null && appleName.trim().isNotEmpty)
                ? appleName.trim()
                : (googleName != null && googleName.trim().isNotEmpty)
                    ? googleName.trim()
                    : '';
        if (defaultUsername.isEmpty && user.email != null && user.email!.isNotEmpty) {
          defaultUsername = user.email!.split('@').first;
        }
        if (defaultUsername.isEmpty) {
          defaultUsername = 'MusicLover';
        }
        if (controller.username.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.setUsername(defaultUsername);
          });
        }
        if (usernameController.text.isEmpty) {
          usernameController.text = defaultUsername;
        }
      }
      return null;
    }, []);

    void onContinue() async {
      if (formKey.currentState!.validate()) {
        final uid = locator<FirebaseAuthService>().getUid();
        if (uid != null) {
          final updates = <String, dynamic>{
            'username': controller.username,
            'name': controller.username,
          };
          if (controller.profileImageBytes != null) {
            final downloadUrl = await locator<FirestoreService>().uploadProfileImage(
              uid,
              controller.profileImageBytes!,
            );
            updates['profileImageUrl'] = downloadUrl;
          } else {
            final photo = FirebaseAuth.instance.currentUser?.photoURL;
            if (photo != null && photo.isNotEmpty) {
              updates['profileImageUrl'] = photo;
            }
          }
          await locator<FirestoreService>().updateUserData(uid, updates);
        }
        if (context.mounted) {
          AppRouterGo.push(favoriteGenresView);
        }
      }
    }

    Future<void> onExitAttempt() async {
      final shouldExit = await ProfileSetupExitDialog.show(context, isArtist: false);
      if (shouldExit && context.mounted) {
        await ref.read(authControllerProvider).cancelPendingLogin();
        AppRouterGo.pushRemoveUntil(loginView);
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await onExitAttempt();
      },
      child: Scaffold(
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
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      10.ph,
                      AuthBackButton(onTap: onExitAttempt),
                      14.ph,
                      const AuthLogoHeader(),
                      20.ph,
                      const AuthStepProgress(currentStep: 1),
                    28.ph,
                    Text(
                      "Set Up Your Profile",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: AppColors.primaryWhite,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    8.ph,
                    Text(
                      "Let's personalize your experience",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: AppColors.santagrey,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        20.ph,
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              ImageSourceSheet.show(context, (xFile) async {
                                if (xFile != null) {
                                  final bytes = await xFile.readAsBytes();
                                  controller.setProfileImage(bytes);
                                }
                              });
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 100.w,
                                  height: 100.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.listenerAvatarBg,
                                    border: Border.all(
                                      color: AppColors.listenerChipBorder,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: controller.profileImageBytes != null
                                      ? ClipOval(
                                          child: Image.memory(
                                            controller.profileImageBytes!,
                                            width: 100.w,
                                            height: 100.w,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : (FirebaseAuth.instance.currentUser?.photoURL != null && FirebaseAuth.instance.currentUser!.photoURL!.isNotEmpty)
                                          ? ClipOval(
                                              child: Image.network(
                                                FirebaseAuth.instance.currentUser!.photoURL!,
                                                width: 100.w,
                                                height: 100.w,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Icon(
                                                  CupertinoIcons.camera,
                                                  color: AppColors.gray500,
                                                  size: 32.sp,
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              CupertinoIcons.camera,
                                              color: AppColors.gray500,
                                              size: 32.sp,
                                            ),
                                ),
                                Positioned(
                                  bottom: 2.h,
                                  right: 2.w,
                                  child: Container(
                                    width: 28.w,
                                    height: 28.w,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.listenerYellow,
                                    ),
                                    child: Icon(
                                      CupertinoIcons.camera_fill,
                                      color: AppColors.primaryblack,
                                      size: 13.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        12.ph,
                        Center(
                          child: Text(
                            "Upload Profile Picture",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: AppColors.santagrey,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        32.ph,
                        Text(
                          "Username",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: AppColors.gray300,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        8.ph,
                        CustomTextField(
                          controller: usernameController,
                          hintText: "Choose a username",
                          onChanged: controller.setUsername,
                          fillColor: AppColors.listenerChipBg,
                          enableBorderColor: AppColors.listenerChipBorder,
                          focusedBorderColor: AppColors.listenerYellow,
                          cursorColor: AppColors.primaryWhite,
                          isLast: true,
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
                              AppValidators.validateEmpty(value, 'Username is required'),
                        ),
                        32.ph,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                child: Row(
                  children: [
                    Expanded(
                      child: PrimaryElevatedButton(
                        onTap: () => AppRouterGo.back(),
                        text: "Back",
                        backgroundColor: AppColors.transparent,
                        textColor: AppColors.primaryWhite,
                        radius: 12,
                        buttonStyle: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            side: const BorderSide(color: AppColors.listenerBackButtonBorder),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    16.pw,
                    Expanded(
                      child: PrimaryElevatedButton(
                        onTap: onContinue,
                        text: "Continue",
                        backgroundColor: AppColors.listenerYellow,
                        textColor: AppColors.primaryblack,
                        radius: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
}
}
