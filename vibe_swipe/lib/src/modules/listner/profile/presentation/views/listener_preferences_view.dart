import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/components/auth_step_progress.dart';
import '../controllers/listener_profile_controller.dart';
import '../widgets/notification_tile.dart';

class ListenerPreferencesView extends ConsumerWidget {
  const ListenerPreferencesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(listenerProfileControllerProvider);
    final notifier = ref.read(listenerProfileControllerProvider.notifier);

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
              const ListenerPageHeader(title: 'Settings'),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: const AuthStepProgress(currentStep: 2),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      24.ph,
                      Text(
                        'Favorite Genres',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryWhite,
                          fontFamily: 'Roboto',
                          height: 1.0,
                          letterSpacing: 0,
                        ),
                      ),
                      16.ph,
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 12.h,
                        children: controller.genres.map((genre) {
                          return GenreChip(
                            label: genre,
                            isSelected: controller.favoriteGenres.contains(
                              genre,
                            ),
                            isDisabled: controller.dislikedGenres.contains(
                              genre,
                            ),
                            onTap: () => notifier.toggleFavorite(genre),
                          );
                        }).toList(),
                      ),
                      28.ph,
                      Text(
                        'Disliked Genres',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryWhite,
                          fontFamily: 'Roboto',
                          height: 1.0,
                          letterSpacing: 0,
                        ),
                      ),
                      16.ph,
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 12.h,
                        children: controller.genres.map((genre) {
                          return GenreChip(
                            label: genre,
                            isSelected: controller.dislikedGenres.contains(
                              genre,
                            ),
                            selectedColor: AppColors.listenerDislikeRed,
                            selectedTextColor: AppColors.primaryWhite,
                            isDisabled: controller.favoriteGenres.contains(
                              genre,
                            ),
                            onTap: () => notifier.toggleDisliked(genre),
                          );
                        }).toList(),
                      ),
                      28.ph,
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryWhite,
                          fontFamily: 'Roboto',
                          height: 1.0,
                          letterSpacing: 0,
                        ),
                      ),
                      16.ph,
                      ...[
                        _NotifToggle('New Songs', 'Get notified about new releases', controller.newSongs, notifier.toggleNewSongs),
                        _NotifToggle('Promotions', 'Updates about campaigns and rewards', controller.promotions, notifier.togglePromotions),
                        _NotifToggle('App Updates', 'New features and improvements', controller.appUpdates, notifier.toggleAppUpdates),
                      ].asMap().entries.map((entry) {
                        final t = entry.value;
                        final isLast = entry.key == 2;
                        return Column(
                          children: [
                            NotificationTile(
                              title: t.title,
                              subtitle: t.subtitle,
                              value: t.value,
                              onChanged: t.onChanged,
                            ),
                            if (!isLast) 12.ph,
                          ],
                        );
                      }),
                      32.ph,
                      PrimaryElevatedButton(
                        onTap: notifier.onSaveSettings,
                        text: 'Save Settings',
                        backgroundColor: AppColors.listenerYellow,
                        textColor: AppColors.primaryblack,
                        radius: 14,
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
    );
  }
}

class _NotifToggle {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifToggle(this.title, this.subtitle, this.value, this.onChanged);
}
