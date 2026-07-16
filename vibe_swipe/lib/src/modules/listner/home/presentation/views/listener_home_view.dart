import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../../performances/domain/entities/performance_featured_entity.dart';
import '../../../performances/domain/entities/performance_upcoming_entity.dart';
import '../controllers/listener_home_controller.dart';
import '../../../dashboard/presentation/controllers/listener_dashboard_controller.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_filter_chips.dart';
import '../widgets/home_card_stack.dart';
import '../widgets/home_action_buttons.dart';
import '../../../../../components/like_confetti_overlay.dart';

class ListenerHomeView extends ConsumerStatefulWidget {
  const ListenerHomeView({super.key});

  @override
  ConsumerState<ListenerHomeView> createState() => _ListenerHomeViewState();
}

class _ListenerHomeViewState extends ConsumerState<ListenerHomeView> {
  bool _showConfetti = false;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(listenerHomeControllerProvider);
    final notifier = ref.read(listenerHomeControllerProvider.notifier);
    final dashboardNotifier = ref.read(
      listenerDashboardControllerProvider.notifier,
    );

    void onPlayTap(int index) {
      notifier.togglePlay();
    }

    void onCardTap(int index) {
      final card = controller.cards[index];
      if (card.videoUrl.isEmpty) return;

      if (card.status == 'upcoming') {
        AppRouterGo.push(
          listenerUpcomingPerformanceDetailView,
          extra: PerformanceUpcomingEntity(
            id: card.performanceId,
            title: card.title.isNotEmpty ? card.title : card.caption,
            artist: card.name,
            genre: card.song,
            time: '',
            thumbnailUrl: card.imageUrl,
            artistImageUrl: card.artistImageUrl,
            videoUrl: card.videoUrl,
            artistId: card.artistId,
            description: card.caption,
            type: card.type,
          ),
        );
      } else {
        AppRouterGo.push(
          listenerLivePerformanceView,
          extra: PerformanceFeaturedEntity(
            id: card.performanceId,
            title: card.title.isNotEmpty ? card.title : card.caption,
            artist: card.name,
            genre: card.song,
            viewCount: card.likes,
            isLive: card.status == 'live',
            thumbnailUrl: card.imageUrl,
            videoUrl: card.videoUrl,
            artistId: card.artistId,
            description: card.caption,
          ),
        );
      }
    }

    return SafeArea(
      bottom: false,
      child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(20.r),
                  bottomLeft: Radius.circular(20.r),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.snowWhite.withValues(alpha: 0.4),
                    width: 1.w,
                  ),
                ),
              ),
              child: Column(
                children: [
                  HomeAppBar(
                    onSearchTap: () => dashboardNotifier.onTabTapped(1),
                  ),
                  16.ph,
                  HomeFilterChips(
                    selected: controller.selectedFilter,
                    onSelected: notifier.onFilterSelected,
                  ),
                  16.ph,
                ],
              ),
            ),
            10.ph,
            Expanded(
              child: LikeConfettiOverlay(
                showConfetti: _showConfetti,
                child: controller.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.listenerYellow,
                        ),
                      )
                    : controller.cards.isEmpty
                        ? Center(
                            child: Text(
                              'No performances available yet',
                              style: TextStyle(
                                color: AppColors.huegrey,
                                fontSize: 14.sp,
                              ),
                            ),
                          )
                        : HomeCardStack(
                            cards: controller.cards,
                            currentIndex: controller.currentIndex,
                            dragOffset: controller.dragOffset,
                            onDragUpdate: notifier.onDragUpdate,
                            onDragEnd: notifier.onDragEnd,
                            currentCardSwipeDirection: controller.currentCardSwipeDirection,
                            isPlaying: controller.isPlaying,
                            isFollowedAt: (index) => notifier.isFollowed(controller.cards[index].artistId),
                            isBookmarkedAt: (index) => controller.isBookmarked(index),
                            onPlayTap: onPlayTap,
                            onCardTap: onCardTap,
                            onBookmarkTap: (index) => notifier.toggleBookmark(index),
                            onFollowTap: (index) => notifier.toggleFollow(index),
                          ),
              ),
            ),
            24.ph,
            if (!controller.isLoading && controller.cards.isNotEmpty)
              HomeActionButtons(
                onDislike: () => notifier.swipe(liked: false),
                onLike: () {
                  notifier.swipe(liked: true);
                  setState(() => _showConfetti = true);
                  Future.delayed(const Duration(milliseconds: 2100), () {
                    if (mounted) setState(() => _showConfetti = false);
                  });
                },
              ),
            12.ph,
            Text(
              'Scroll to browse  ·  Use buttons to like or skip',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.whitesmoke,
                letterSpacing: 0.2,
              ),
            ),
            16.ph,
          ],
        ),
    );
  }
}
