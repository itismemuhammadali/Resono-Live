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
