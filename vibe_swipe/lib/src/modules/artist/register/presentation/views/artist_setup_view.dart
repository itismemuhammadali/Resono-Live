import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/utils/app_exports.dart';
import '../../../../../components/primary_elevated_button.dart';
import '../../../../../components/auth_logo_header.dart';
import '../../../../authentication/presentation/widgets/auth_back_button.dart';
import '../../../../authentication/presentation/widgets/profile_setup_exit_dialog.dart';
import '../../../../authentication/presentation/controllers/authentication_controller.dart';
import '../controllers/artist_register_controller.dart';
import '../widgets/artist_avatar_picker.dart';
import '../widgets/artist_banner_picker.dart';
import '../widgets/artist_labeled_field.dart';
import '../widgets/artist_social_links.dart';
import '../widgets/artist_public_profile_toggle.dart';

class ArtistSetupView extends HookConsumerWidget {
  const ArtistSetupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerController = ref.watch(artistRegisterControllerProvider);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final bioController = useTextEditingController();
    final genreError = useState(false);

    useEffect(() {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (nameController.text.isEmpty && user.displayName != null && user.displayName!.isNotEmpty) {
          nameController.text = user.displayName!;
        }
      }
      return null;
    }, []);

    void onContinue() async {
      final isFormValid = formKey.currentState!.validate();
      final hasGenre = registerController.selectedGenres.isNotEmpty;
      genreError.value = !hasGenre;
      if (isFormValid && hasGenre) {
        final uid = locator<FirebaseAuthService>().getUid();
        if (uid != null) {
          String? profileImageUrl;
          if (registerController.pickedImageBytes != null) {
            profileImageUrl = await locator<FirestoreService>().uploadProfileImage(uid, registerController.pickedImageBytes!);
          } else {
            final photo = FirebaseAuth.instance.currentUser?.photoURL;
            if (photo != null && photo.isNotEmpty) {
              profileImageUrl = photo;
            }
          }
          String? coverUrl;
          if (registerController.pickedBannerImageBytes != null) {
            coverUrl = await locator<FirestoreService>().uploadBannerImage(uid, registerController.pickedBannerImageBytes!);
          }
          await locator<FirestoreService>().saveArtistProfile(
            uid: uid,
            artistName: nameController.text.trim(),
            bio: bioController.text.trim(),
            genres: registerController.selectedGenres.toList(),
            spotifyUrl: registerController.spotifyUrl,
            youtubeUrl: registerController.youtubeUrl,
            instagramUrl: registerController.instagramUrl,
            isPublicProfile: registerController.isPublicProfile,
            profileImageUrl: profileImageUrl,
            coverUrl: coverUrl,
          );
        }
        if (context.mounted) {
          AppRouterGo.pushRemoveUntil(artistDashboardView);
        }
      }
    }

    Future<void> onExitAttempt() async {
      final shouldExit = await ProfileSetupExitDialog.show(context, isArtist: true);
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
                    AuthBackButton(onTap: onExitAttempt),
                    20.ph,
                    const AuthLogoHeader(),
                  28.ph,
                  ArtistAvatarPicker(
                    imageBytes: registerController.pickedImageBytes,
                    onPicked: (XFile? file) {
                      if (file != null) {
                        ref
                            .read(artistRegisterControllerProvider)
                            .setProfileImage(file);
                      }
                    },
                  ),
                  24.ph,
                  ArtistBannerPicker(
                    imageBytes: registerController.pickedBannerImageBytes,
                    onPicked: (XFile? file) {
                      if (file != null) {
                        ref
                            .read(artistRegisterControllerProvider)
                            .setBannerImage(file);
                      }
                    },
                  ),
                  32.ph,
                  ArtistLabeledField(
                    label: "Artist Name",
                    hintText: "New Artist",
                    controller: nameController,
                    prefixWidget: Icon(
                      CupertinoIcons.person,
                      color: AppColors.gray500,
                      size: 20.sp,
                    ),
                    textCapitalization: TextCapitalization.words,
                    onChanged: (val) => ref
                        .read(artistRegisterControllerProvider)
                        .setArtistName(val),
                    validator: (value) =>
                        AppValidators.validateEmpty(value, 'Artist name is required'),
                  ),
                  24.ph,
                  ArtistLabeledField(
                    label: "Bio",
                    hintText: "Tell your story...",
                    controller: bioController,
                    maxLines: 5,
                    minLines: 4,
                    textInputType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: (val) =>
                        ref.read(artistRegisterControllerProvider).setBio(val),
                    validator: (value) =>
                        AppValidators.validateEmpty(value, 'Bio is required'),
                  ),
                  24.ph,
                  Text(
                    "Genres",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: AppColors.gray300,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  12.ph,
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: registerController.genres.map((genre) {
                      return GenreChip(
                        label: genre,
                        isSelected: registerController.selectedGenres.contains(genre),
                        onTap: () {
                          ref
                              .read(artistRegisterControllerProvider)
                              .toggleGenre(genre);
                          if (genreError.value) {
                            genreError.value =
                                registerController.selectedGenres.isEmpty;
                          }
                        },
                      );
                    }).toList(),
                  ),
                  if (genreError.value) ...[
                    8.ph,
                    Text(
                      'Please select at least one genre',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: AppColors.eventRed,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                  24.ph,
                  ArtistSocialLinks(
                    onSpotifyChanged: (val) => ref
                        .read(artistRegisterControllerProvider)
                        .setSpotifyUrl(val),
                    onYoutubeChanged: (val) => ref
                        .read(artistRegisterControllerProvider)
                        .setYoutubeUrl(val),
                    onInstagramChanged: (val) => ref
                        .read(artistRegisterControllerProvider)
                        .setInstagramUrl(val),
                    spotifyValidator: AppValidators.validateOptionalUrl,
                    youtubeValidator: AppValidators.validateOptionalUrl,
                    instagramValidator: AppValidators.validateOptionalUrl,
                  ),
                  24.ph,
                  ArtistPublicProfileToggle(
                    value: registerController.isPublicProfile,
                    onChanged: (val) => ref
                        .read(artistRegisterControllerProvider)
                        .togglePublicProfile(val),
                  ),
                  40.ph,
                  PrimaryElevatedButton(
                    onTap: onContinue,
                    text: "Continue to Dashboard",
                    backgroundColor: AppColors.listenerYellow,
                    textColor: AppColors.primaryblack,
                    radius: 12,
                  ),
                  24.ph,
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
