import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/artist_home_controller.dart';
import '../widgets/active_campaigns_section.dart';
import '../widgets/artist_home_app_bar.dart';
import '../widgets/artist_stats_grid.dart';
import '../widgets/payout_setup_banner.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/recent_activity_section.dart';
import '../../../../../components/meta_ad_placement_widget.dart';

class ArtistHomeView extends ConsumerWidget {
  const ArtistHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(artistHomeControllerProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArtistHomeAppBar(artistName: controller.artistName),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.hasCheckedPayouts && !controller.stripePayoutsEnabled) ...[
                    16.ph,
                    const PayoutSetupBanner(),
                  ],
                  24.ph,
                  ArtistStatsGrid(stats: controller.stats),
                  24.ph,
                  const QuickActionsSection(),
                  24.ph,
                  ActiveCampaignsSection(campaigns: controller.campaigns),
                  24.ph,
                  const MetaAdPlacementWidget(
                    type: MetaAdPlacementType.mediumRectangle,
                    placementName: 'Artist Dashboard',
                    isTestMode: true,
                  ),
                  24.ph,
                  RecentActivitySection(activities: controller.recentActivity),
                  32.ph,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
