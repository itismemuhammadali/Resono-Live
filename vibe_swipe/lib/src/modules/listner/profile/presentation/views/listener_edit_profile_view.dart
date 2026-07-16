import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/components/custom_textfield.dart';
import '../controllers/listener_profile_controller.dart';
import '../widgets/field_label.dart';

class ListenerEditProfileView extends HookConsumerWidget {
  const ListenerEditProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(listenerProfileControllerProvider);
    final notifier = ref.read(listenerProfileControllerProvider.notifier);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final fullNameController = useTextEditingController(text: controller.name);
    final usernameController = useTextEditingController(text: controller.username);
    final emailController = useTextEditingController(text: controller.email);
    final fullNameFocus = useFocusNode();
    final usernameFocus = useFocusNode();
    final emailFocus = useFocusNode();

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
          child: Column(
            children: [
              const ListenerPageHeader(title: 'Edit Profile'),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          children: [
                            24.ph,
                            Center(
                              child: GestureDetector(
                                onTap: () =>
                                    notifier.showImageSourceSheet(context),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 96.w,
                                      height: 96.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.listenerActiveTab,
                                          width: 1.09.w,
                                        ),
                                      ),
                                      child: controller.pickedImageBytes != null
                                          ? ClipOval(
                                              child: Image.memory(
                                                controller.pickedImageBytes!,
                                                fit: BoxFit.cover,
                                                width: 96.w,
                                                height: 96.w,
                                              ),
                                            )
                                          : controller.profileImageUrl.isNotEmpty
                                              ? ClipOval(
                                                  child: CachedNetworkImage(
                                                    imageUrl: controller.profileImageUrl,
                                                    width: 96.w,
                                                    height: 96.w,
                                                    fit: BoxFit.cover,
                                                    cacheKey: controller.profileImageUrl,
                                                    memCacheWidth: 192,
                                                    errorWidget: (_, __, ___) => Container(
                                                      color: AppColors.listenerChipBg,
                                                      child: Icon(
                                                        Icons.person,
                                                        color: AppColors.gray500,
                                                        size: 40.sp,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : ClipOval(
                                                  child: Container(
                                                    color: AppColors.listenerChipBg,
                                                    child: Icon(
                                                      Icons.person,
                                                      color: AppColors.gray500,
                                                      size: 40.sp,
                                                    ),
                                                  ),
                                                ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 28.w,
                                        height: 28.w,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.listenerActiveTab,
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
                            Text(
                              'Tap to change profile picture',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.huegrey,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            16.ph,
                          ],
                        ),
                      ),
                      Divider(color: AppColors.listenerBackButtonBorder),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Form(
                          key: formKey,
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            24.ph,
                            FieldLabel(label: 'Full Name'),
                            8.ph,
                            CustomTextField(
                              controller: fullNameController,
                              focusNode: fullNameFocus,
                              onEditingComplete: () => FocusScope.of(
                                context,
                              ).requestFocus(usernameFocus),
                              hintText: 'Enter your full name',
                              isPrefix: true,
                              prefixWidget: Icon(
                                Icons.person_outline,
                                color: AppColors.huegrey,
                                size: 20.sp,
                              ),
                              fillColor: const Color(0xFF121821),
                              enableBorderColor: AppColors.primaryWhite
                                  .withValues(alpha: 0.10),
                              focusedBorderColor: AppColors.listenerActiveTab,
                              cursorColor: AppColors.primaryWhite,
                              fieldBorderRadius: 16,
                              borderWidth: 1.09,
                              textStyle: TextStyle(
                                fontFamily: 'Roboto',
                                color: AppColors.primaryWhite,
                                fontSize: 14.sp,
                              ),
                              hintTextStyle: TextStyle(
                                fontFamily: 'Roboto',
                                color: AppColors.huegrey,
                                fontSize: 14.sp,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 20.h,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Full name is required';
                                }
                                if (value.trim().length < 2) {
                                  return 'Name must be at least 2 characters';
                                }
                                if (value.trim().length > 50) {
                                  return 'Name must be under 50 characters';
                                }
                                return null;
                              },
                            ),
                            20.ph,
                            FieldLabel(label: 'Username'),
                            8.ph,
                            CustomTextField(
                              controller: usernameController,
                              focusNode: usernameFocus,
                              onEditingComplete: () => FocusScope.of(
                                context,
                              ).requestFocus(emailFocus),
                              hintText: 'Enter your username',
                              fillColor: const Color(0xFF121821),
                              enableBorderColor: AppColors.primaryWhite
                                  .withValues(alpha: 0.10),
                              focusedBorderColor: AppColors.listenerActiveTab,
                              cursorColor: AppColors.primaryWhite,
                              fieldBorderRadius: 16,
                              borderWidth: 1.09,
                              textStyle: TextStyle(
                                fontFamily: 'Roboto',
                                color: AppColors.primaryWhite,
                                fontSize: 14.sp,
                              ),
                              hintTextStyle: TextStyle(
                                fontFamily: 'Roboto',
                                color: AppColors.huegrey,
                                fontSize: 14.sp,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 20.h,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Username is required';
                                }
                                if (value.trim().length < 3) {
                                  return 'Username must be at least 3 characters';
                                }
                                if (value.trim().length > 30) {
                                  return 'Username must be under 30 characters';
                                }
                                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                                  return 'Only letters, numbers and underscores allowed';
                                }
                                return null;
                              },
                            ),
                            20.ph,
                            FieldLabel(label: 'Email'),
                            8.ph,
                            CustomTextField(
                              controller: emailController,
                              focusNode: emailFocus,
                              hintText: 'Enter your email',
                              isPrefix: true,
                              prefixWidget: Icon(
                                Icons.email_outlined,
                                color: AppColors.huegrey,
                                size: 20.sp,
                              ),
                              textInputType: TextInputType.emailAddress,
                              isLast: true,
                              fillColor: const Color(0xFF121821),
                              enableBorderColor: AppColors.primaryWhite
                                  .withValues(alpha: 0.10),
                              focusedBorderColor: AppColors.listenerActiveTab,
                              cursorColor: AppColors.primaryWhite,
                              fieldBorderRadius: 16,
                              borderWidth: 1.09,
                              textStyle: TextStyle(
                                fontFamily: 'Roboto',
                                color: AppColors.primaryWhite,
                                fontSize: 14.sp,
                              ),
                              hintTextStyle: TextStyle(
                                fontFamily: 'Roboto',
                                color: AppColors.huegrey,
                                fontSize: 14.sp,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 20.h,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$')
                                    .hasMatch(value.trim())) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            32.ph,
                            PrimaryElevatedButton(
                              onTap: () {
                                if (formKey.currentState?.validate() ?? false) {
                                  notifier.onSaveChanges(
                                    name: fullNameController.text.trim(),
                                    username: usernameController.text.trim(),
                                    email: emailController.text.trim(),
                                  );
                                }
                              },
                              text: 'Save Changes',
                              backgroundColor: AppColors.listenerYellow,
                              textColor: AppColors.primaryblack,
                              radius: 14,
                            ),
                            12.ph,
                            PrimaryElevatedButton(
                              onTap: notifier.onCancel,
                              text: 'Cancel',
                              backgroundColor: AppColors.transparent,
                              textColor: AppColors.primaryWhite,
                              radius: 14,
                              buttonStyle: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                  side: const BorderSide(
                                    color: AppColors.listenerBackButtonBorder,
                                  ),
                                ),
                                elevation: 0,
                              ),
                            ),
                            24.ph,
                          ],
                        ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
