import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../../home/presentation/widgets/artist_home_app_bar.dart';
import '../controllers/artist_analytics_controller.dart';
import '../widgets/engagement_by_genre_card.dart';
import '../widgets/plays_over_time_card.dart';
import '../widgets/section_header.dart';
import '../widgets/stats_grid.dart';
import '../widgets/top_performing_tracks_card.dart';

class ArtistAnalyticsView extends ConsumerWidget {
  const ArtistAnalyticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(artistAnalyticsControllerProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArtistHomeAppBar(artistName: controller.artistName),
          Expanded(
            child: controller.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.listenerActiveTab,
                      strokeWidth: 2.5,
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        24.ph,
                        SectionHeader(
                          selectedPeriod: controller.selectedPeriod,
                          onPeriodSelected: controller.selectPeriod,
                        ),
                        20.ph,
                        StatsGrid(stats: controller.stats),
                        24.ph,
                        PlaysOverTimeCard(chartData: controller.chartData),
                        24.ph,
                        EngagementByGenreCard(genres: controller.genreData),
                        24.ph,
                        TopPerformingTracksCard(tracks: controller.topTracks),
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
