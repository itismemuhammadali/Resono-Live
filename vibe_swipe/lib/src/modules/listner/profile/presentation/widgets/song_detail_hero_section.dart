import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../data/dtos/library_song_dto.dart';

class SongDetailHeroSection extends StatelessWidget {
  const SongDetailHeroSection({super.key, required this.song});

  final LibrarySongDto song;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _CoverImage(song: song),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _HeroButton(
                      icon: Icons.chevron_left,
                      onTap: AppRouterGo.back,
                    ),
                    _HeroButton(icon: Icons.share_rounded, onTap: () {}),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 7.h,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(60.r),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: 0.35,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.listenerYellow,
                              borderRadius: BorderRadius.circular(60.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  12.pw,
                  Text(
                    '${song.duration ?? '0:00'} Sec',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.primaryWhite,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 8.h,
            right: 5.w,
            child: Image.asset(
              AppAssetsPng.songPlayBtnIcn,
              width: 100.w,
              height: 100.w,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.song});

  final LibrarySongDto song;

  @override
  Widget build(BuildContext context) {
    return NetworkSnap(
      imageUrl: song.coverUrl,
      width: 1.sw,
      height: 260.h,
      fit: BoxFit.cover,
      borderRadiusGeometry: BorderRadius.only(
        bottomLeft: Radius.circular(20.r),
        bottomRight: Radius.circular(20.r),
      ),
      errorWidget: (_, __, ___) => _GradientFallback(colors: song.coverColors),
    );
  }
}

class _GradientFallback extends StatelessWidget {
  const _GradientFallback({required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: AppColors.primaryWhite.withValues(alpha: 0.25),
          size: 72.sp,
        ),
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        padding: EdgeInsets.symmetric(horizontal: 8.9.w),
        decoration: BoxDecoration(
          color: AppColors.listenerChipBg,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: AppColors.primaryWhite.withValues(alpha: 0.10),
            width: 1.09.w,
          ),
        ),
        child: Icon(icon, color: AppColors.primaryWhite, size: 20.sp),
      ),
    );
  }
}
