import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/artist_stat_entity.dart';

class ArtistStatsGrid extends StatelessWidget {
  const ArtistStatsGrid({super.key, required this.stats});

  final List<ArtistStatEntity> stats;

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

  final ArtistStatEntity stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: 16.circular,
        border: Border(
          top: BorderSide(
            color: AppColors.primaryWhite.withValues(alpha: 0.1),
            width: 1.09,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconRow(),
          8.ph,
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 30.sp,
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
        ],
      ),
    );
  }

  Widget _buildIconRow() {
    final hasSecond = stat.secondIconAsset != null || stat.secondIcon != null;
    if (hasSecond) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSingleIcon(stat.iconAsset, stat.icon, stat.iconColor),
          6.pw,
          _buildSingleIcon(
            stat.secondIconAsset,
            stat.secondIcon,
            stat.secondIconColor,
          ),
        ],
      );
    }
    return _buildSingleIcon(stat.iconAsset, stat.icon, stat.iconColor);
  }

  Widget _buildSingleIcon(
    String? asset,
    IconData? fallbackIcon,
    Color? color,
  ) {
    if (asset != null) {
      return Image.asset(asset, width: 32.w, height: 32.w, color: color);
    }
    if (fallbackIcon != null) {
      return Icon(fallbackIcon, color: color, size: 32.w);
    }
    return const SizedBox.shrink();
  }
}
