import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/post_card_entity.dart';

class HomeSwipeCard extends StatelessWidget {
  const HomeSwipeCard({
    super.key,
    required this.card,
    required this.width,
    required this.height,
    required this.swipeDirection,
    this.dimmed = false,
    this.onPlayTap,
    this.onBookmarkTap,
    this.onCardTap,
    this.onFollowTap,
    this.onOptionsTap,
    this.isPlaying = false,
    this.isFollowed = false,
    this.isBookmarked = false,
  });

  final PostCardEntity card;
  final double width;
  final double height;
  final int swipeDirection;
  final bool dimmed;
  final VoidCallback? onPlayTap;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onCardTap;
  final VoidCallback? onFollowTap;
  final VoidCallback? onOptionsTap;
  final bool isPlaying;
  final bool isFollowed;
  final bool isBookmarked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
        children: [
          // Background image
          NetworkSnap(
            imageUrl: card.imageUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            borderRadiusGeometry: BorderRadius.circular(20.r),
            errorWidget: (_, __, ___) => DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4B1A8A),
                    Color(0xFF2A0D5E),
                    Color(0xFF1A0A3A),
                    Color(0xFF0D121B),
                  ],
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ),

          // Bottom gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.9875],
                  colors: [
                    Color(0x00121821),
                    Color(0xFF121821),
                  ],
                ),
              ),
            ),
          ),

          // Live indicator badge top-left
          if (card.status == 'live')
            Positioned(
              top: 16.h,
              left: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    6.pw,
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Play/pause button top-right
          Positioned(
            top: 10.h,
            right: 16.w,
            child: GestureDetector(
              onTap: onPlayTap,
              child: isPlaying
                  ? Container(
                      width: 60.h,
                      height: 60.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                      child: Icon(
                        Icons.pause_rounded,
                        color: AppColors.primaryWhite,
                        size: 36.h,
                      ),
                    )
                  : Image.asset(
                      'assets/icons/png/home_play_button_icn.png',
                      width: 60.h,
                      height: 60.h,
                    ),
            ),
          ),

          // Bottom info row
          Positioned(
            bottom: 10.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Info area
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        card.name,
                        style: TextStyle(
                          color: AppColors.primaryWhite,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      6.ph,
                      Text(
                        card.caption,
                        style: TextStyle(
                          color: AppColors.primaryWhite,
                          fontSize: 16.sp,
                          height: 1.375,
                          letterSpacing: -0.16,
                        ),
                      ),
                      6.ph,
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/png/music_note_icn.png',
                            width: 18.w,
                            height: 18.w,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.music_note_rounded,
                              size: 14.sp,
                              color: AppColors.primaryWhite,
                            ),
                          ),
                          5.pw,
                          Flexible(
                            child: Text(
                              card.song,
                              style: TextStyle(
                                color: AppColors.primaryWhite,
                                fontSize: 13.sp,
                                letterSpacing: -0.13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                10.pw,
                // Sidebar
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar + follow button
                    SizedBox(
                      width: 48.w,
                      height: 57.h,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: 0,
                            child: Container(
                              width: 48.w,
                              height: 48.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.listenerAvatarBg,
                                border: Border.all(
                                  color: AppColors.listenerYellow,
                                  width: 2,
                                ),
                              ),
                              child: card.artistImageUrl.isNotEmpty
                                  ? ClipOval(
                                      child: NetworkSnap(
                                        imageUrl: card.artistImageUrl,
                                        width: 48.w,
                                        height: 48.w,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person_rounded,
                                      color: AppColors.huegrey,
                                      size: 22.sp,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: _FollowButton(
                              isFollowed: isFollowed,
                              onTap: onFollowTap,
                            ),
                          ),
                        ],
                      ),
                    ),
                    15.ph,
                    // Bookmark + count
                    GestureDetector(
                      onTap: onBookmarkTap,
                      child: Column(
                        children: [
                          Icon(
                            isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: isBookmarked
                                ? AppColors.listenerActiveTab
                                : AppColors.primaryWhite,
                            size: 26.sp,
                          ),
                          8.ph,
                          Text(
                            card.likes,
                            style: TextStyle(
                              color: AppColors.primaryWhite,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.12,
                              shadows: const [
                                Shadow(
                                  color: Color(0x40000000),
                                  offset: Offset(1, 1),
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onOptionsTap != null) ...[
                      14.ph,
                      GestureDetector(
                        onTap: onOptionsTap,
                        child: Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.35),
                          ),
                          child: Icon(
                            Icons.more_horiz_rounded,
                            color: AppColors.primaryWhite,
                            size: 22.sp,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Swipe direction overlay (LIKE / SKIP)
          if (swipeDirection != 0)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: (swipeDirection > 0
                          ? AppColors.mintGreen
                          : AppColors.listenerDislikeRed)
                      .withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: swipeDirection > 0
                            ? AppColors.mintGreen
                            : AppColors.listenerDislikeRed,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      swipeDirection > 0 ? 'LIKE' : 'SKIP',
                      style: TextStyle(
                        color: swipeDirection > 0
                            ? AppColors.mintGreen
                            : AppColors.listenerDislikeRed,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Dim overlay for adjacent cards
          if (dimmed)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: AppColors.listenerDashboardBg.withValues(alpha: 0.35),
              ),
            ),
        ],
      ),
      ),
    );
  }
}

class _FollowButton extends StatefulWidget {
  const _FollowButton({
    required this.isFollowed,
    this.onTap,
  });

  final bool isFollowed;
  final VoidCallback? onTap;

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(_FollowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFollowed && !oldWidget.isFollowed) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(
            color: widget.isFollowed
                ? AppColors.mintGreen
                : AppColors.listenerYellow,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.isFollowed ? Icons.check_rounded : Icons.add_rounded,
            color: AppColors.primaryblack,
            size: 14.sp,
          ),
        ),
      ),
    );
  }
}
