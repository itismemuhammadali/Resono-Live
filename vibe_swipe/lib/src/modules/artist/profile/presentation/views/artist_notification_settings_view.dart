import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../widgets/notification_settings_card.dart';

class ArtistNotificationSettingsView extends ConsumerWidget {
  const ArtistNotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const ArtistPageHeader(title: 'Notification Settings'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    top: 0.h,
                    bottom: 16.h,
                  ),
                  child: const NotificationSettingsCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
