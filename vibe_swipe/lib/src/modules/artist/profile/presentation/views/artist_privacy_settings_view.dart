import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../widgets/privacy_settings_card.dart';
import '../widgets/artist_privacy_info_card.dart';

class ArtistPrivacySettingsView extends StatelessWidget {
  const ArtistPrivacySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
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
              const ArtistPageHeader(title: 'Privacy Settings'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    top: 0.h,
                    bottom: 16.h,
                  ),
                  child: Column(
                    children: [
                      const PrivacySettingsCard(),
                      24.ph,
                      const ArtistPrivacyInfoCard(),
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
