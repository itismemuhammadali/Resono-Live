import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/analytics_top_track_entity.dart';

class TopPerformingTracksCard extends StatelessWidget {
  const TopPerformingTracksCard({super.key, required this.tracks});

  final List<AnalyticsTopTrackEntity> tracks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: 16.circular,
        border: Border.all(
          color: AppColors.primaryWhite.withValues(alpha: 0.10),
          width: 1.09,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Performing Tracks',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryWhite,
            ),
          ),
          16.ph,
          if (tracks.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: Text(
                  'No tracks data yet',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.huegrey,
                  ),
                ),
              ),
            )
          else
            ...tracks.map(
            (track) => Padding(
              padding: EdgeInsets.only(bottom: tracks.last == track ? 0 : 12.h),
              child: _TrackRow(track: track),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({required this.track});

  final AnalyticsTopTrackEntity track;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RankBadge(rank: track.rank),
        12.pw,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                track.title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryWhite,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              4.ph,
              Text(
                '${track.plays} plays',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.huegrey,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${track.likes} likes',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.mintGreen,
              ),
            ),
            4.ph,
            Text(
              '${track.saves} saves',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.huegrey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: AppColors.listenerActiveTab.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '#$rank',
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.listenerActiveTab,
        ),
      ),
    );
  }
}
