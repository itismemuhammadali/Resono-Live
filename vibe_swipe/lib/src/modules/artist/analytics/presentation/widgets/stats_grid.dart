import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/analytics_stat_entity.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.stats});

  final List<AnalyticsStatEntity> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        if (stats.length >= 2)
          Row(
            children: [
              Expanded(child: _StatCard(stat: stats[0])),
              12.pw,
              Expanded(child: _StatCard(stat: stats[1])),
            ],
          ),
        if (stats.length >= 2) 12.ph,
        if (stats.length >= 4)
          Row(
            children: [
              Expanded(child: _StatCard(stat: stats[2])),
              12.pw,
              Expanded(child: _StatCard(stat: stats[3])),
            ],
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final AnalyticsStatEntity stat;

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
          _StatIcon(stat: stat),
          8.ph,
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryWhite,
            ),
          ),
          8.ph,
          Text(
            stat.label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.huegrey,
            ),
          ),
          if (stat.change.isNotEmpty) ...[
            8.ph,
            Row(
              children: [
                Image.asset(
                  stat.isPositive
                      ? 'assets/icons/png/artist_analytics_upward_arrow_icn.png'
                      : 'assets/icons/png/artist_analytics_downward_arrow_icn.png',
                ),
                5.pw,
                Text(
                  stat.change,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: stat.isPositive
                        ? AppColors.mintGreen
                        : AppColors.listenerDislikeRed,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatIcon extends StatelessWidget {
  const _StatIcon({required this.stat});

  final AnalyticsStatEntity stat;

  @override
  Widget build(BuildContext context) {
    return Image.asset(stat.icon);
  }
}
