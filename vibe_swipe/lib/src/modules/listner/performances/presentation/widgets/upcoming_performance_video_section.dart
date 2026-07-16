import 'package:video_player/video_player.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class UpcomingPerformanceVideoSection extends StatelessWidget {
  const UpcomingPerformanceVideoSection({
    super.key,
    required this.thumbnailUrl,
    required this.isPlaying,
    required this.isVideoInitialized,
    required this.onPlayPause,
    this.videoController,
  });

  final String thumbnailUrl;
  final bool isPlaying;
  final bool isVideoInitialized;
  final VoidCallback onPlayPause;
  final VideoPlayerController? videoController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isVideoInitialized && videoController != null)
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
            NetworkSnap(
              imageUrl: thumbnailUrl,
              width: 1.sw,
              height: 260.h,
              fit: BoxFit.cover,
              radius: 0,
              errorWidget: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1B0040), Color(0xFF0D2040), Color(0xFF001A10)],
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppColors.primaryblack.withValues(alpha: 0.75), AppColors.transparent],
                ),
              ),
            ),
          ),
          Positioned(top: 16.h, left: 16.w, child: const CircularBackButton()),
          Center(
            child: GestureDetector(
              onTap: onPlayPause,
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryblack.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_outlined,
                  color: AppColors.primaryWhite,
                  size: 30.sp,
                ),
              ),
            ),
          ),
          if (isVideoInitialized && videoController != null)
            Positioned(
              bottom: 14.h,
              left: 16.w,
              right: 16.w,
              child: _ProgressBarWithVideo(controller: videoController!),
            ),
        ],
      ),
    );
  }
}

class _ProgressBarWithVideo extends StatelessWidget {
  const _ProgressBarWithVideo({required this.controller});
  final VideoPlayerController controller;

  String _formatTime(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final total = value.duration.inMilliseconds;
        final current = value.position.inMilliseconds;
        final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
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
            ),
            6.ph,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(value.position), style: TextStyle(
                  fontFamily: 'Roboto', fontSize: 12.sp, fontWeight: FontWeight.w400,
                  color: AppColors.primaryWhite.withValues(alpha: 0.6),
                )),
                Text(_formatTime(value.duration), style: TextStyle(
                  fontFamily: 'Roboto', fontSize: 12.sp, fontWeight: FontWeight.w400,
                  color: AppColors.primaryWhite.withValues(alpha: 0.6),
                )),
              ],
            ),
          ],
        );
      },
    );
  }
}
