import '../../../../../core/utils/app_exports.dart';
import '../../../../../components/primary_elevated_button.dart';
import '../../../../../components/auth_logo_header.dart';
import '../controllers/listener_register_controller.dart';
import '../../../../../components/auth_step_progress.dart';

class FavoriteGenresView extends HookConsumerWidget {
  const FavoriteGenresView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(listenerRegisterControllerProvider);

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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    10.ph,
                    const AuthLogoHeader(),
                    20.ph,
                    const AuthStepProgress(currentStep: 2),
                    28.ph,
                    Text(
                      "Favorite Genres",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: AppColors.primaryWhite,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    8.ph,
                    Text(
                      "Select what you love to listen to",
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 8.h,
                  ),
                  child: Wrap(
                    spacing: 10.w,
                    runSpacing: 12.h,
                    children: controller.genres.map((genre) {
                      return GenreChip(
                        label: genre,
                        isSelected: controller.favoriteGenres.contains(genre),
                        isDisabled: controller.dislikedGenres.contains(genre),
                        onTap: () => ref
                            .read(listenerRegisterControllerProvider)
                            .toggleFavorite(genre),
                      );
                    }).toList(),
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
                        onTap: () async {
                          final uid = locator<FirebaseAuthService>().getUid();
                          if (uid != null) {
                            await locator<FirestoreService>().updateUserData(uid, {
                              'favoriteGenres': controller.favoriteGenres.toList(),
                            });
                          }
                          if (context.mounted) {
                            AppRouterGo.push(dislikedGenresView);
                          }
                        },
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
  );
}
}
