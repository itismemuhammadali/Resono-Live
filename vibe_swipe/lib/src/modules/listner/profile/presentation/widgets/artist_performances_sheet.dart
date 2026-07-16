import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../../performances/domain/entities/performance_upcoming_entity.dart';
import '../../../performances/domain/entities/performance_featured_entity.dart';

class ArtistPerformancesSheet extends StatelessWidget {
  const ArtistPerformancesSheet({
    super.key,
    required this.performances,
    required this.artistName,
    required this.artistImageUrl,
  });

  final List<Map<String, dynamic>> performances;
  final String artistName;
  final String artistImageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: AppColors.listenerDashboardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          12.ph,
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.huegrey,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          16.ph,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "$artistName's Performances",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryWhite,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => AppRouterGo.back(),
                  child: Icon(Icons.close, color: AppColors.huegrey, size: 24.sp),
                ),
              ],
            ),
          ),
          16.ph,
          Expanded(
            child: performances.isEmpty
                ? Center(
                    child: Text(
                      'No performances yet',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.huegrey,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    itemCount: performances.length,
                    separatorBuilder: (_, __) => 12.ph,
                    itemBuilder: (context, index) {
                      final p = performances[index];
                      return _PerformanceTile(
                        performance: p,
                        artistName: artistName,
                        artistImageUrl: artistImageUrl,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceTile extends StatelessWidget {
  const _PerformanceTile({
    required this.performance,
    required this.artistName,
    required this.artistImageUrl,
  });

  final Map<String, dynamic> performance;
  final String artistName;
  final String artistImageUrl;

  @override
  Widget build(BuildContext context) {
    final title = (performance['title'] ?? performance['name'] ?? 'Untitled').toString();
    final status = (performance['status'] ?? 'upcoming').toString();
    final thumbnailUrl = (performance['thumbnailUrl'] ?? '').toString();
    final viewersCount = performance['viewers_count'] ?? performance['viewCount'] ?? 0;
    final isLive = status == 'live';

    return GestureDetector(
      onTap: () {
        AppRouterGo.back();
        if (isLive) {
          AppRouterGo.push(
            listenerLivePerformanceView,
            extra: PerformanceFeaturedEntity(
              id: (performance['id'] ?? '').toString(),
              title: title,
              artist: artistName,
              genre: 'Music',
              viewCount: '$viewersCount',
              isLive: true,
              thumbnailUrl: thumbnailUrl,
              videoUrl: (performance['videoUrl'] ?? '').toString(),
              artistId: (performance['artist_id'] ?? '').toString(),
              artistImageUrl: artistImageUrl,
              description: (performance['description'] ?? performance['caption'] ?? '').toString(),
            ),
          );
        } else {
          AppRouterGo.push(
            listenerUpcomingPerformanceDetailView,
            extra: PerformanceUpcomingEntity(
              id: (performance['id'] ?? '').toString(),
              title: title,
              artist: artistName,
              genre: 'Music',
              time: '',
              thumbnailUrl: thumbnailUrl,
              artistImageUrl: artistImageUrl,
              videoUrl: (performance['videoUrl'] ?? '').toString(),
              artistId: (performance['artist_id'] ?? '').toString(),
              description: (performance['description'] ?? performance['caption'] ?? '').toString(),
              views: viewersCount is int ? viewersCount : 0,
              type: (performance['type'] ?? 'live').toString(),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.listenerChipBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.primaryWhite.withValues(alpha: 0.10),
            width: 1.09.w,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                width: 60.w,
                height: 60.w,
                child: thumbnailUrl.isNotEmpty
                    ? Image.network(thumbnailUrl, fit: BoxFit.cover)
                    : Container(
                        color: AppColors.listenerActiveTab.withValues(alpha: 0.2),
                        child: Icon(
                          Icons.play_circle_outline_rounded,
                          color: AppColors.listenerActiveTab,
                          size: 28.sp,
                        ),
                      ),
              ),
            ),
            12.pw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryWhite,
                    ),
                  ),
                  4.ph,
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: isLive
                              ? AppColors.listenerDislikeRed.withValues(alpha: 0.2)
                              : AppColors.listenerActiveTab.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          isLive ? 'LIVE' : status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: isLive ? AppColors.listenerDislikeRed : AppColors.listenerActiveTab,
                          ),
                        ),
                      ),
                      8.pw,
                      Text(
                        '$viewersCount views',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.huegrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.huegrey, size: 24.sp),
          ],
        ),
      ),
    );
  }
}
