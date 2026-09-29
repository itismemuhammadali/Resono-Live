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
import '../../../../../components/meta_ad_placement_widget.dart';
import 'package:vibe_swipe/src/core/utils/report_block_helper.dart';


class ListenerHomeView extends ConsumerStatefulWidget {
  const ListenerHomeView({super.key});

  @override
  ConsumerState<ListenerHomeView> createState() => _ListenerHomeViewState();
}

class _ListenerHomeViewState extends ConsumerState<ListenerHomeView> {
  bool _showConfetti = false;
  PageController? _pageController;
  bool _isAnimating = false;

  PageController _ensurePageController(int initialPage) {
    if (_pageController == null) {
      final screenWidth = MediaQuery.sizeOf(context).width;
      final peekAmount = 30.w;
      final cardGap = 10.w;
      final cardWidth = screenWidth - (peekAmount + cardGap) * 2;
      final fraction = ((cardWidth + cardGap) / screenWidth).clamp(0.7, 0.95);
      _pageController = PageController(
        initialPage: initialPage,
        viewportFraction: fraction,
      );
    }
    return _pageController!;
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _handleDislike() async {
    if (_isAnimating) return;
    final controller = ref.read(listenerHomeControllerProvider);
    final notifier = ref.read(listenerHomeControllerProvider.notifier);

    notifier.swipe(liked: false);

    if (_pageController != null &&
        _pageController!.hasClients &&
        controller.currentIndex < controller.cards.length - 1) {
      _isAnimating = true;
      try {
        await _pageController!.nextPage(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
        );
      } finally {
        _isAnimating = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(listenerHomeControllerProvider);
    final notifier = ref.read(listenerHomeControllerProvider.notifier);
    final pageController = _ensurePageController(controller.currentIndex);
    final dashboardNotifier = ref.read(
      listenerDashboardControllerProvider.notifier,
    );

    void onPlayTap(int index) {
      notifier.togglePlay();
    }

    void onCardTap(int index) {
      if (index >= controller.cards.length) return;
      final card = controller.cards[index];

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
      } else if (card.status == 'live') {
        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            backgroundColor: AppColors.listenerDashboardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
              side: const BorderSide(
                color: AppColors.listenerChipBorder,
                width: 1,
              ),
            ),
            title: Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent,
                  ),
                ),
                8.pw,
                Expanded(
                  child: Text(
                    '${card.name} is Live',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryWhite,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'Would you like to tune in to this live stream performance?',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14.sp,
                color: AppColors.huegrey,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: AppColors.huegrey,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.listenerYellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  AppRouterGo.push(
                    listenerLivePerformanceView,
                    extra: PerformanceFeaturedEntity(
                      id: card.performanceId,
                      title: card.title.isNotEmpty ? card.title : card.caption,
                      artist: card.name,
                      genre: card.song,
                      viewCount: card.likes,
                      isLive: true,
                      thumbnailUrl: card.imageUrl,
                      videoUrl: card.videoUrl,
                      artistId: card.artistId,
                      description: card.caption,
                    ),
                  );
                },
                child: Text(
                  'Join Live',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryblack,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        notifier.togglePlay();
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
            const MetaAdPlacementWidget(
              type: MetaAdPlacementType.banner,
              placementName: 'Listener Home',
              isTestMode: true,
            ),
            10.ph,

            Expanded(
              child: LikeConfettiOverlay(
                showConfetti: _showConfetti,
                child: controller.isLoading
                    ? const Center(
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
                            cardRatings: controller.cardRatings,
                            pageController: pageController,
                            onPageChanged: notifier.onPageChanged,
                            isPlaying: controller.isPlaying,
                            isFollowedAt: (index) => notifier.isFollowed(controller.cards[index].artistId),
                            isBookmarkedAt: (index) => controller.isBookmarked(index),
                            onPlayTap: onPlayTap,
                            onCardTap: onCardTap,
                            onBookmarkTap: (index) => notifier.toggleBookmark(index),
                            onFollowTap: (index) => notifier.toggleFollow(index),
                            onOptionsTap: (index) {
                              final card = controller.cards[index];
                              ReportBlockHelper.showArtistOptionsModal(
                                context,
                                artistId: card.artistId,
                                artistName: card.name,
                                onArtistBlocked: () {
                                  ref.read(listenerHomeControllerProvider).removeCardsForArtist(card.artistId);
                                },
                              );
                            },
                          ),
              ),
            ),
            24.ph,
            if (!controller.isLoading && controller.cards.isNotEmpty)
              HomeActionButtons(
                onDislike: _handleDislike,
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
