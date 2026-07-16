import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../data/dtos/artist_dto.dart';

class ArtistHeroSection extends StatelessWidget {
  const ArtistHeroSection({super.key, required this.artist});

  final ArtistDto artist;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _CoverImage(artist: artist),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _HeroButton(
                    icon: Icons.chevron_left,
                    onTap: AppRouterGo.back,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.artist});

  final ArtistDto artist;

  @override
  Widget build(BuildContext context) {
    return NetworkSnap(
      imageUrl: artist.coverUrl,
      width: 1.sw,
      height: 260.h,
      fit: BoxFit.cover,
      borderRadiusGeometry: BorderRadius.only(
        bottomLeft: Radius.circular(20.r),
        bottomRight: Radius.circular(20.r),
      ),
      errorWidget: (_, __, ___) =>
          _GradientFallback(colors: artist.coverColors),
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
          Icons.person_rounded,
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
