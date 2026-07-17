import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/performance_upcoming_entity.dart';
import '../controllers/listener_performances_controller.dart';
import '../widgets/upcoming_performance_video_section.dart';
import '../widgets/upcoming_performance_artist_row.dart';
import '../widgets/upcoming_performance_stats_row.dart';
import '../widgets/upcoming_performance_action_buttons.dart';
import '../widgets/upcoming_performance_quick_actions_section.dart';

class ListenerUpcomingPerformanceDetailView extends ConsumerStatefulWidget {
  const ListenerUpcomingPerformanceDetailView({
    super.key,
    required this.performance,
  });

  final PerformanceUpcomingEntity performance;

  @override
  ConsumerState<ListenerUpcomingPerformanceDetailView> createState() => _ListenerUpcomingPerformanceDetailViewState();
}

class _ListenerUpcomingPerformanceDetailViewState extends ConsumerState<ListenerUpcomingPerformanceDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listenerPerformancesControllerProvider.notifier).setCurrentPerformance(widget.performance.id, artistId: widget.performance.artistId);
      if (widget.performance.videoUrl.isNotEmpty) {
        ref.read(listenerPerformancesControllerProvider.notifier).initVideo(widget.performance.videoUrl);
      }
    });
  }

  void _sharePerformance() {
    final id = widget.performance.id;
    final title = widget.performance.title;
    if (id.isNotEmpty) {
      Share.share(
        "Check out this performance on VibeSwipe: '$title'\n"
        "https://vibeswipe.page.link/performance-detail?performanceId=$id",
      );
    }
  }

  @override

  Widget build(BuildContext context) {
    final controller = ref.watch(listenerPerformancesControllerProvider);
    final notifier = ref.read(listenerPerformancesControllerProvider.notifier);

    final description = widget.performance.description.isNotEmpty
        ? widget.performance.description
        : 'Epic ${widget.performance.genre.toLowerCase()} performance featuring '
            'the biggest hits and fan favorites.';

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            UpcomingPerformanceVideoSection(
              thumbnailUrl: widget.performance.thumbnailUrl,
              isPlaying: controller.isPlaying,
              isVideoInitialized: controller.isVideoInitialized,
              onPlayPause: notifier.togglePlay,
              videoController: controller.videoController,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    20.ph,
                    UpcomingPerformanceArtistRow(performance: widget.performance),
                    14.ph,
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.performance.title,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryWhite,
                            ),
                          ),
                        ),
                        8.pw,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: widget.performance.isRecorded
                                ? const Color(0xFF4A90A4).withValues(alpha: 0.2)
                                : AppColors.listenerYellow.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            widget.performance.isRecorded ? 'Recorded' : 'Live',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: widget.performance.isRecorded
                                  ? const Color(0xFF4A90A4)
                                  : AppColors.listenerYellow,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    10.ph,
                    UpcomingPerformanceStatsRow(views: widget.performance.views),
                    14.ph,
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryWhite.withValues(alpha: 0.6),
                        height: 1.65,
                      ),
                    ),
                    24.ph,
                    UpcomingPerformanceActionButtons(
                      isLiked: controller.isLiked,
                      isSaved: controller.isSaved,
                      likesCount: controller.likesCount,
                      onLike: notifier.toggleLike,
                      onSave: notifier.toggleSave,
                      onShare: _sharePerformance,
                    ),
                    16.ph,
                    Divider(color: AppColors.listenerBackButtonBorder),
                    16.ph,
                    UpcomingPerformanceQuickActionsSection(
                      artist: widget.performance.artist,
                      artistId: widget.performance.artistId,
                      performanceId: widget.performance.id,
                      performanceTitle: widget.performance.title,
                    ),
                    40.ph,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
