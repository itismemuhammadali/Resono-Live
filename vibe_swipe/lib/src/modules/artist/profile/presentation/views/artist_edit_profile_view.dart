import 'package:flutter/cupertino.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/components/custom_textfield.dart';
import '../controllers/artist_profile_controller.dart';
import '../widgets/public_profile_tile.dart';

class ArtistEditProfileView extends HookConsumerWidget {
  const ArtistEditProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(artistProfileControllerProvider);
    final notifier = ref.read(artistProfileControllerProvider.notifier);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final nameController = useTextEditingController(text: controller.artistName);
    final emailController = useTextEditingController(
      text: controller.artistEmail,
    );
    final bioController = useTextEditingController(
      text: controller.bio,
    );
    final spotifyController = useTextEditingController(text: controller.spotifyUrl);
    final youtubeController = useTextEditingController(text: controller.youtubeUrl);
    final instagramController = useTextEditingController(text: controller.instagramUrl);

    final nameFocus = useFocusNode();
    final emailFocus = useFocusNode();
    final bioFocus = useFocusNode();
    final spotifyFocus = useFocusNode();
    final youtubeFocus = useFocusNode();
    final instagramFocus = useFocusNode();

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
              const ArtistPageHeader(title: 'Edit Profile'),
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
                                    notifier.showBannerSourceSheet(context),
                                child: Container(
                                  width: double.infinity,
                                  height: 160.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.listenerChipBg,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: AppColors.primaryWhite.withValues(alpha: 0.10),
                                      width: 1.09.w,
                                    ),
                                  ),
                                  child: controller.pickedBannerImageBytes != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(16.r),
                                          child: Image.memory(
                                            controller.pickedBannerImageBytes!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 160.h,
                                          ),
                                        )
                                      : controller.bannerUrl != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(16.r),
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  NetworkSnap(
                                                    imageUrl: controller.bannerUrl,
                                                    width: double.infinity,
                                                    height: 160.h,
                                                    fit: BoxFit.cover,
                                                    borderRadiusGeometry: BorderRadius.circular(16.r),
                                                  ),
                                                  Positioned(
                                                    bottom: 8,
                                                    right: 8,
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primaryblack.withValues(alpha: 0.6),
                                                        borderRadius: BorderRadius.circular(8.r),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            CupertinoIcons.camera,
                                                            color: AppColors.primaryWhite,
                                                            size: 14.sp,
                                                          ),
                                                          6.pw,
                                                          Text(
                                                            'Change',
                                                            style: TextStyle(
                                                              fontFamily: 'Roboto',
                                                              color: AppColors.primaryWhite,
                                                              fontSize: 12.sp,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.landscape_rounded,
                                                  color: AppColors.gray500,
                                                  size: 40.sp,
                                                ),
                                                12.ph,
                                                Text(
                                                  'Upload banner image',
                                                  style: TextStyle(
                                                    fontFamily: 'Roboto',
                                                    color: AppColors.primaryWhite,
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                8.ph,
                                                Text(
                                                  'Recommended: 1500x500px',
                                                  style: TextStyle(
                                                    fontFamily: 'Roboto',
                                                    color: AppColors.huegrey,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                ),
                              ),
                            ),
                            16.ph,
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
                                          color: AppColors.primaryWhite
                                              .withValues(alpha: 0.10),
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
                                          : ClipOval(
                                              child: Container(
                                                width: 96.w,
                                                height: 96.w,
                                                color: AppColors.listenerChipBg,
                                                child: Icon(
                                                  CupertinoIcons.camera,
                                                  color: AppColors.huegrey,
                                                  size: 32.sp,
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
                                          CupertinoIcons.camera,
                                          color: AppColors.primaryblack,
                                          size: 13.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            16.ph,
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              24.ph,
                              _fieldLabel('Artist Name'),
                              8.ph,
                              _buildTextField(
                                controller: nameController,
                                focusNode: nameFocus,
                                hintText: 'Enter artist name',
                                isPrefix: true,
                                prefixWidget: Icon(
                                  Icons.person_outline,
                                  color: AppColors.huegrey,
                                  size: 20.sp,
                                ),
                                onEditingComplete: () => FocusScope.of(
                                  context,
                                ).requestFocus(emailFocus),
                              ),
                              20.ph,
                              _fieldLabel('Enter Email'),
                              8.ph,
                              _buildTextField(
                                controller: emailController,
                                focusNode: emailFocus,
                                hintText: 'Enter email address',
                                isPrefix: true,
                                prefixWidget: Icon(
                                  Icons.email_outlined,
                                  color: AppColors.huegrey,
                                  size: 20.sp,
                                ),
                                textInputType: TextInputType.emailAddress,
                                onEditingComplete: () => FocusScope.of(
                                  context,
                                ).requestFocus(bioFocus),
                              ),
                              20.ph,
                              _fieldLabel('Bio'),
                              8.ph,
                              _buildTextField(
                                controller: bioController,
                                focusNode: bioFocus,
                                hintText: 'Tell us about yourself...',
                                maxLines: 5,
                                minLines: 4,
                              ),
                              24.ph,
                              _fieldLabel('Genres'),
                              12.ph,
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 10.h,
                                children: ArtistProfileController.genreOptions
                                    .map(
                                      (genre) => GenreChip(
                                        label: genre,
                                        isSelected: controller.selectedGenres
                                            .contains(genre),
                                        onTap: () =>
                                            notifier.toggleGenre(genre),
                                      ),
                                    )
                                    .toList(),
                              ),
                              24.ph,
                              _fieldLabel('Social Links'),
                              12.ph,
                              _buildTextField(
                                controller: spotifyController,
                                focusNode: spotifyFocus,
                                hintText: 'Spotify URL',
                                textInputType: TextInputType.url,
                                onEditingComplete: () => FocusScope.of(
                                  context,
                                ).requestFocus(youtubeFocus),
                              ),
                              10.ph,
                              _buildTextField(
                                controller: youtubeController,
                                focusNode: youtubeFocus,
                                hintText: 'YouTube URL',
                                textInputType: TextInputType.url,
                                onEditingComplete: () => FocusScope.of(
                                  context,
                                ).requestFocus(instagramFocus),
                              ),
                              10.ph,
                              _buildTextField(
                                controller: instagramController,
                                focusNode: instagramFocus,
                                hintText: 'Instagram URL',
                                textInputType: TextInputType.url,
                                isLast: true,
                              ),
                              24.ph,
                              PublicProfileTile(
                                value: controller.publicProfile,
                                onChanged: notifier.togglePublicProfile,
                              ),
                              32.ph,
                              PrimaryElevatedButton(
                                onTap: () {
                                  if (formKey.currentState?.validate() ??
                                      false) {
                                    notifier.onSaveChanges(
                                      artistName: nameController.text.trim(),
                                      bio: bioController.text.trim(),
                                      spotifyUrl: spotifyController.text.trim(),
                                      youtubeUrl: youtubeController.text.trim(),
                                      instagramUrl: instagramController.text.trim(),
                                    );
                                  } else {
                                    notifier.onSaveChanges(
                                      artistName: nameController.text.trim(),
                                      bio: bioController.text.trim(),
                                      spotifyUrl: spotifyController.text.trim(),
                                      youtubeUrl: youtubeController.text.trim(),
                                      instagramUrl: instagramController.text.trim(),
                                    );
                                  }
                                },
                                text: 'Save Changes',
                                backgroundColor: AppColors.listenerYellow,
                                textColor: AppColors.primaryblack,
                                radius: 14,
                              ),
                              32.ph,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    bool isPrefix = false,
    Widget? prefixWidget,
    TextInputType textInputType = TextInputType.text,
    int maxLines = 1,
    int? minLines,
    bool isLast = false,
    VoidCallback? onEditingComplete,
  }) {
    return CustomTextField(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText,
      isPrefix: isPrefix,
      prefixWidget: prefixWidget,
      textInputType: textInputType,
      maxLines: maxLines,
      minLines: minLines,
      isLast: isLast,
      onEditingComplete: onEditingComplete,
      fillColor: AppColors.listenerChipBg,
      enableBorderColor: AppColors.primaryWhite.withValues(alpha: 0.10),
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
        vertical: maxLines > 1 ? 16.h : 20.h,
      ),
    );
  }
}

Widget _fieldLabel(String label) {
  return Text(
    label,
    style: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.gray300,
      fontFamily: 'Roboto',
    ),
  );
}
