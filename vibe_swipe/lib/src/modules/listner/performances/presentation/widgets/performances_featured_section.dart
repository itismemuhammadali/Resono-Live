import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/performance_featured_entity.dart';
import 'performances_section_title.dart';

class PerformancesFeaturedSection extends StatelessWidget {
  const PerformancesFeaturedSection({super.key, required this.featured});

  final PerformanceFeaturedEntity featured;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PerformancesSectionTitle(
          image: 'assets/icons/png/home_new_filter_icn.png',
          title: 'Featured Today',
        ),
        16.ph,
        _FeaturedCard(featured: featured),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.featured});

  final PerformanceFeaturedEntity featured;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRouterGo.push(
        listenerLivePerformanceView,
        extra: featured,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: SizedBox(
          height: 200.h,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              NetworkSnap(
                imageUrl: featured.thumbnailUrl,
                width: 1.sw,
                height: 180.h,
                fit: BoxFit.cover,
                radius: 20,
                errorWidget: (_, __, ___) => Container(
                  width: 1.sw,
                  height: 180.h,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1B0040),
                        Color(0xFF0D2040),
                        Color(0xFF001A10),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.4, 1.0],
                      colors: [
                        Colors.transparent,
                        AppColors.primaryblack.withValues(alpha: 0.78),
                      ],
                    ),
                  ),
                ),
              ),
              if (featured.isLive)
                Positioned(top: 12.h, left: 12.w, child: const _LiveBadge()),
              Positioned(
                top: 12.h,
                right: 12.w,
                child: _ViewCount(count: featured.viewCount),
              ),
              Positioned(
                top: 100.h,
                left: 0,
                right: 0,
                child: Center(child: _GenreChip(label: featured.genre)),
              ),
              Positioned(
                bottom: 16.h,
                left: 16.w,
                right: 16.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      featured.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryWhite,
                      ),
                    ),
                    4.ph,
                    Text(
                      featured.artist,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryWhite.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.listenerLiveRed,
        borderRadius: BorderRadius.circular(600.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/icons/png/performances_live_icn.png'),
          8.pw,
          Text(
            'LIVE',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryWhite,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewCount extends StatelessWidget {
  const _ViewCount({required this.count});

  final String count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primaryblack.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(600.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_outlined,
            color: AppColors.primaryWhite,
            size: 14.sp,
          ),
          8.pw,
          Text(
            count,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryWhite,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.listenerActiveTab.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(600.r),
        border: Border.all(color: AppColors.listenerActiveTab, width: 1.09.w),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.listenerActiveTab,
        ),
      ),
    );
  }
}
