import 'package:flutter/cupertino.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import '../controllers/listener_profile_controller.dart';
import '../widgets/notification_tile.dart';
import '../widgets/privacy_info_card.dart';

class ListenerPrivacySettingsView extends ConsumerWidget {
  const ListenerPrivacySettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(listenerProfileControllerProvider);
    final notifier = ref.read(listenerProfileControllerProvider.notifier);

    final toggles = [
      _PrivacyToggle(
        title: 'Public Profile',
        subtitle: 'Allow others to view your profile',
        value: controller.publicProfile,
        onChanged: notifier.togglePublicProfile,
      ),
      _PrivacyToggle(
        title: 'Listening History',
        subtitle: 'Show your recently played songs publicly',
        value: controller.listeningHistory,
        onChanged: notifier.toggleListeningHistory,
      ),
      _PrivacyToggle(
        title: 'Saved Songs',
        subtitle: 'Make your saved songs visible to others',
        value: controller.savedSongs,
        onChanged: notifier.toggleSavedSongs,
      ),
      _PrivacyToggle(
        title: 'Data Collection',
        subtitle: 'Help improve recommendations',
        value: controller.dataCollection,
        onChanged: notifier.toggleDataCollection,
      ),
      _PrivacyToggle(
        title: 'Share with Artists',
        subtitle: 'Allow artists to see when you listen',
        value: controller.shareWithArtists,
        onChanged: notifier.toggleShareWithArtists,
      ),
    ];

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
              const ListenerPageHeader(title: 'Privacy Settings'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      16.ph,
                      const PrivacyInfoCard(),
                      24.ph,
                      for (var i = 0; i < toggles.length; i++) ...[
                        NotificationTile(
                          title: toggles[i].title,
                          subtitle: toggles[i].subtitle,
                          value: toggles[i].value,
                          onChanged: toggles[i].onChanged,
                        ),
                        if (i < toggles.length - 1) 12.ph,
                      ],
                      32.ph,
                      PrimaryElevatedButton(
                        onTap: notifier.onSavePrivacySettings,
                        text: 'Save Settings',
                        backgroundColor: AppColors.listenerYellow,
                        textColor: AppColors.primaryblack,
                        radius: 14,
                      ),
                      16.ph,
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.deleteRed, width: 1),
                            backgroundColor: AppColors.deleteRed.withValues(alpha: 0.15),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          onPressed: () {
                            showCupertinoDialog(
                              context: context,
                              builder: (ctx) => CupertinoAlertDialog(
                                title: const Text('Delete Account'),
                                content: const Text(
                                  'Are you sure you want to delete your account? This action is permanent and cannot be undone.',
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text('Cancel'),
                                    onPressed: () => Navigator.pop(ctx),
                                  ),
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    child: const Text('Delete Account'),
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      await AuthHandler.ref.deleteAccount();
                                      if (context.mounted) {
                                        AppRouterGo.pushReplacement(loginView);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_forever_outlined, color: AppColors.deleteRed, size: 20.sp),
                              8.pw,
                              Text(
                                'Delete Account',
                                style: AppTextTheme.titleMediumBlack16?.copyWith(
                                  color: AppColors.deleteRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}

class _PrivacyToggle {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrivacyToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
}
