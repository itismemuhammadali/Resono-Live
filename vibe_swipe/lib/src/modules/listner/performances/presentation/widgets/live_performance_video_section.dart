import 'package:video_player/video_player.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/performance_featured_entity.dart';

class LivePerformanceVideoSection extends StatelessWidget {
  const LivePerformanceVideoSection({
    super.key,
    required this.featured,
    required this.isPlaying,
    required this.isVideoInitialized,
    required this.onPlayPause,
    required this.isLive,
    this.videoController,
    this.liveChild,
    this.isFullScreen = false,
  });

  final PerformanceFeaturedEntity featured;
  final bool isPlaying;
  final bool isVideoInitialized;
  final VoidCallback onPlayPause;
  final bool isLive;
  final VideoPlayerController? videoController;
  final Widget? liveChild;
  final bool isFullScreen;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: isFullScreen
          ? BorderRadius.zero
          : BorderRadius.vertical(bottom: Radius.circular(20.r)),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Live Agora stream or pre-recorded fallback
            if (liveChild != null)
              liveChild!
            else if (isVideoInitialized && videoController != null)
              GestureDetector(
                onTap: onPlayPause,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: videoController!.value.aspectRatio,
                    child: VideoPlayer(videoController!),
                  ),
                ),
              )
            else
              _VideoBackground(thumbnailUrl: featured.thumbnailUrl),

            // Gradient overlay — darker at bottom for readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: const Alignment(0, 0.0),
                    colors: [
                      AppColors.primaryblack.withValues(alpha: 0.80),
                      AppColors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Top row: Back button (left) + LIVE badge (right)
            if (!isFullScreen)
              Positioned(
                top: 30.h,
                left: 20.w,
                right: 20.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CircularBackButton(),
                    if (featured.isLive) const _LiveBadge(),
                  ],
                ),
              ),

            // Watching count pill — below back button
            if (!isFullScreen)
              Positioned(
                top: 90.h,
                left: 20.w,
                child: _WatchingCount(count: featured.viewCount),
              ),

            // Center play button — only for pre-recorded content
            if (!isLive && !isFullScreen)
              Center(
                child: GestureDetector(
                  onTap: onPlayPause,
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryblack.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryWhite.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_outlined,
                      color: AppColors.primaryWhite,
                      size: 40.sp,
                    ),
                  ),
                ),
              ),

            // Bottom: Artist info card + progress bar
            if (!isFullScreen)
              Positioned(
                bottom: 20.h,
              left: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 14.h),
                    child: Row(
                      children: [
                        // Artist avatar
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.listenerAvatarBg,
                          ),
                          child: NetworkSnap(
                            imageUrl: featured.artistImageUrl,
                            width: 44.w,
                            height: 44.w,
                            fit: BoxFit.cover,
                            borderRadiusGeometry: BorderRadius.circular(22.w),
                            errorWidget: (_, __, ___) => Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFFFF8C42), Color(0xFFFF6B35)],
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 24.sp,
                                color: AppColors.primaryWhite,
                              ),
                            ),
                          ),
                        ),
                        12.pw,
                        // Artist name + genre
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                featured.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryWhite,
                                ),
                              ),
                              2.ph,
                              Text(
                                featured.genre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.primaryWhite.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress bar — hidden during live streaming
                  if (!isLive)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: isVideoInitialized && videoController != null
                          ? _VideoProgressBar(controller: videoController!)
                          : _StaticProgressBar(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoBackground extends StatelessWidget {
  const _VideoBackground({this.thumbnailUrl = ''});
  final String thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: NetworkSnap(
        imageUrl: thumbnailUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        radius: 0,
        errorWidget: (_, __, ___) => Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1B0040), Color(0xFF0D2040), Color(0xFF001A10)],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.listenerLiveRed,
        borderRadius: BorderRadius.circular(600.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/icons/png/performances_live_icn.png'),
          10.pw,
          Text(
            'LIVE',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryWhite,
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchingCount extends StatelessWidget {
  const _WatchingCount({required this.count});
  final String count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primaryblack.withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(600.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_outlined, color: AppColors.primaryWhite.withValues(alpha: 0.8), size: 14.sp),
          8.pw,
          Text(
            '$count watching',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryWhite.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3.h,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              Container(width: constraints.maxWidth * 0.35, color: AppColors.listenerActiveTab),
              Expanded(child: Container(color: AppColors.primaryWhite.withValues(alpha: 0.25))),
            ],
          );
        },
      ),
    );
  }
}

class _VideoProgressBar extends StatelessWidget {
  const _VideoProgressBar({required this.controller});
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final total = value.duration.inMilliseconds;
        final current = value.position.inMilliseconds;
        final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

        return GestureDetector(
          onTapDown: (details) {
            final box = context.findRenderObject() as RenderBox;
            final newProgress = (details.localPosition.dx / box.size.width).clamp(0.0, 1.0);
            controller.seekTo(Duration(milliseconds: (newProgress * total).round()));
          },
          onHorizontalDragUpdate: (details) {
            final box = context.findRenderObject() as RenderBox;
            final newProgress = (details.localPosition.dx / box.size.width).clamp(0.0, 1.0);
            controller.seekTo(Duration(milliseconds: (newProgress * total).round()));
          },
          child: SizedBox(
            height: 3.h,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Container(width: constraints.maxWidth * progress, color: AppColors.listenerActiveTab),
                    Expanded(child: Container(color: AppColors.primaryWhite.withValues(alpha: 0.25))),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
