import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/post_card_entity.dart';
import 'home_swipe_card.dart';

class HomeCardStack extends StatelessWidget {
  const HomeCardStack({
    super.key,
    required this.cards,
    required this.currentIndex,
    required this.dragOffset,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.currentCardSwipeDirection,
    this.onPlayTap,
    this.onBookmarkTap,
    this.onCardTap,
    this.onFollowTap,
    this.isPlaying = false,
    this.isFollowedAt,
    this.isBookmarkedAt,
  });

  final List<PostCardEntity> cards;
  final int currentIndex;
  final Offset dragOffset;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;
  final int currentCardSwipeDirection;
  final ValueChanged<int>? onPlayTap;
  final ValueChanged<int>? onBookmarkTap;
  final ValueChanged<int>? onCardTap;
  final ValueChanged<int>? onFollowTap;
  final bool isPlaying;
  final bool Function(int index)? isFollowedAt;
  final bool Function(int index)? isBookmarkedAt;

  @override
  Widget build(BuildContext context) {
    final visible = cards.length - currentIndex;
    if (visible <= 0) {
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

        final currentCardLeft = peekAmount + cardGap;
        final prevCardLeft = currentCardLeft - cardWidth - cardGap;
        final nextCardLeft = currentCardLeft + cardWidth + cardGap;

        final dx = dragOffset.dx;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: onDragUpdate,
          onPanEnd: onDragEnd,
          child: ClipRect(
            child: SizedBox(
              width: totalWidth,
              height: cardHeight,
              child: Stack(
                children: [
                  if (currentIndex > 0)
                    Positioned(
                      left: prevCardLeft + dx,
                      top: 0,
                      width: cardWidth,
                      height: cardHeight,
                      child: HomeSwipeCard(
                        card: cards[currentIndex - 1],
                        width: cardWidth,
                        height: cardHeight,
                        swipeDirection: 0,
                        dimmed: true,
                      ),
                    ),

                  if (currentIndex + 1 < cards.length)
                    Positioned(
                      left: nextCardLeft + dx,
                      top: 0,
                      width: cardWidth,
                      height: cardHeight,
                      child: HomeSwipeCard(
                        card: cards[currentIndex + 1],
                        width: cardWidth,
                        height: cardHeight,
                        swipeDirection: 0,
                        dimmed: true,
                      ),
                    ),

                  Positioned(
                    left: currentCardLeft + dx,
                    top: 0,
                    width: cardWidth,
                    height: cardHeight,
                    child: HomeSwipeCard(
                      card: cards[currentIndex],
                      width: cardWidth,
                      height: cardHeight,
                      swipeDirection: currentCardSwipeDirection,
                      isPlaying: isPlaying,
                      isFollowed: isFollowedAt != null ? isFollowedAt!(currentIndex) : false,
                      isBookmarked: isBookmarkedAt != null ? isBookmarkedAt!(currentIndex) : false,
                      onPlayTap: onPlayTap != null ? () => onPlayTap!(currentIndex) : null,
                      onBookmarkTap: onBookmarkTap != null ? () => onBookmarkTap!(currentIndex) : null,
                      onCardTap: onCardTap != null ? () => onCardTap!(currentIndex) : null,
                      onFollowTap: onFollowTap != null ? () => onFollowTap!(currentIndex) : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
