import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class UpcomingPerformanceRelatedSection extends StatelessWidget {
  const UpcomingPerformanceRelatedSection({super.key});

  static const _related = [
    (
      title: 'Rock Revolution Live',
      artist: 'Thunder Strike',
      views: '8.2K views',
      duration: '45:32',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?w=400&fit=crop',
    ),
    (
      title: 'Jazz Night Sessions',
      artist: 'Symphony Orchestra',
      views: '5.8K views',
      duration: '38:15',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=400&fit=crop',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Performances',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryWhite,
          ),
        ),
        14.ph,
        ..._related.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _RelatedCard(
              title: item.title,
              artist: item.artist,
              views: item.views,
              duration: item.duration,
              thumbnailUrl: item.thumbnailUrl,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Related Card ─────────────────────────────────────────────────────────────

class _RelatedCard extends StatelessWidget {
  const _RelatedCard({
    required this.title,
    required this.artist,
    required this.views,
    required this.duration,
    required this.thumbnailUrl,
  });

  final String title;
  final String artist;
  final String views;
  final String duration;
  final String thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF121821),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              NetworkSnap(
                imageUrl: thumbnailUrl,
                width: 130.w,
                height: 80.h,
                fit: BoxFit.cover,
                radius: 10,
                errorWidget: (_, __, ___) => Container(
                  width: 130.w,
                  height: 80.h,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2A1A4A), Color(0xFF0D2040)],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Image.asset(
                    'assets/icons/png/performances_play_icn.png',
                    width: 24.w,
                    height: 24.h,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 6.w, bottom: 6.h),
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryblack.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  duration,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryWhite,
                  ),
                ),
              ),
            ],
          ),
          16.pw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryWhite,
                  ),
                ),
                4.ph,
                Text(
                  artist,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryWhite.withValues(alpha: 0.55),
                  ),
                ),
                4.ph,
                Text(
                  views,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryWhite.withValues(alpha: 0.40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
