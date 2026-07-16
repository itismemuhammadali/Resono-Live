import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/modules/artist/profile/presentation/controllers/artist_profile_controller.dart';
import 'package:vibe_swipe/src/modules/artist/profile/presentation/widgets/help_support_email_tile.dart';
import 'package:vibe_swipe/src/modules/artist/profile/presentation/widgets/help_support_hero_banner.dart';
import 'package:vibe_swipe/src/modules/artist/profile/presentation/widgets/help_support_live_chat_tile.dart';
import 'package:vibe_swipe/src/modules/artist/profile/presentation/widgets/help_support_section_label.dart';
import 'package:vibe_swipe/src/modules/artist/profile/presentation/widgets/help_support_topic_tile.dart';

class ArtistHelpSupportView extends ConsumerWidget {
  const ArtistHelpSupportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(artistProfileControllerProvider);

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
              const ArtistPageHeader(title: 'Help & Support'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      0.ph,
                      const HelpSupportHeroBanner(),
                      28.ph,
                      const HelpSupportSectionLabel(label: 'Popular Topics'),
                      16.ph,
                      if (controller.topics.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Center(
                            child: Text(
                              'No topics available yet.',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.huegrey,
                              ),
                            ),
                          ),
                        )
                      else
                        ...controller.topics.map(
                          (t) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: HelpSupportTopicTile(topic: t),
                          ),
                        ),
                      16.ph,
                      const HelpSupportSectionLabel(label: 'Contact Support'),
                      16.ph,
                      const HelpSupportLiveChatTile(),
                      12.ph,
                      const HelpSupportEmailTile(),
                      32.ph,
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
