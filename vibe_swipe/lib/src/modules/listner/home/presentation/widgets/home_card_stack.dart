import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/post_card_entity.dart';
import 'home_swipe_card.dart';

class HomeCardStack extends StatelessWidget {
  const HomeCardStack({
    super.key,
    required this.cards,
    required this.currentIndex,
    required this.cardRatings,
    required this.pageController,
    required this.onPageChanged,
    this.onPlayTap,
    this.onBookmarkTap,
    this.onCardTap,
    this.onFollowTap,
    this.onOptionsTap,
    this.isPlaying = false,
    this.isFollowedAt,
    this.isBookmarkedAt,
  });

  final List<PostCardEntity> cards;
  final int currentIndex;
  final Map<int, bool> cardRatings;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onPlayTap;
  final ValueChanged<int>? onBookmarkTap;
  final ValueChanged<int>? onCardTap;
  final ValueChanged<int>? onFollowTap;
  final ValueChanged<int>? onOptionsTap;
  final bool isPlaying;
  final bool Function(int index)? isFollowedAt;
  final bool Function(int index)? isBookmarkedAt;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return Center(
        child: Text(
          'No more posts',
          style: TextStyle(color: AppColors.huegrey, fontSize: 14.sp),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;

        final peekAmount = 30.w;
        final cardGap = 10.w;
        final cardWidth = totalWidth - (peekAmount + cardGap) * 2;

        return SizedBox(
          width: totalWidth,
          height: cardHeight,
          child: PageView.builder(
            controller: pageController,
            itemCount: cards.length,
            onPageChanged: onPageChanged,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: pageController,
                builder: (context, child) {
                  double page = currentIndex.toDouble();
                  if (pageController.hasClients &&
                      pageController.position.haveDimensions) {
                    page = pageController.page ?? pageController.initialPage.toDouble();
                  }
                  final diff = (index - page).abs();
                  final isCurrent = diff < 0.5;

                  final rating = cardRatings[index];
                  final swipeDirection = rating == null ? 0 : (rating ? 1 : -1);

                  return Center(
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: HomeSwipeCard(
                        card: cards[index],
                        width: cardWidth,
                        height: cardHeight,
                        swipeDirection: swipeDirection,
                        dimmed: diff > 0.4,
                        isPlaying: isPlaying && isCurrent,
                        isFollowed: isFollowedAt != null ? isFollowedAt!(index) : false,
                        isBookmarked: isBookmarkedAt != null ? isBookmarkedAt!(index) : false,
                        onPlayTap: onPlayTap != null ? () => onPlayTap!(index) : null,
                        onBookmarkTap: onBookmarkTap != null ? () => onBookmarkTap!(index) : null,
                        onCardTap: onCardTap != null ? () => onCardTap!(index) : null,
                        onFollowTap: onFollowTap != null ? () => onFollowTap!(index) : null,
                        onOptionsTap: onOptionsTap != null ? () => onOptionsTap!(index) : null,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
