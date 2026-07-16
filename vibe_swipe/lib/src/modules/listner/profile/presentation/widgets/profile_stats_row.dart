import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    super.key,
    required this.likedCount,
    required this.savedCount,
    required this.genreCount,
  });

  final int likedCount;
  final int savedCount;
  final int genreCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatItem(value: '$likedCount', label: 'Songs Liked')),
        _StatDivider(),
        Expanded(child: _StatItem(value: '$savedCount', label: 'Saved')),
        _StatDivider(),
        Expanded(child: _StatItem(value: '$genreCount', label: 'Genres')),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryWhite,
            fontFamily: 'Roboto',
          ),
        ),
        4.ph,
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.huegrey,
            fontFamily: 'Roboto',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 50.h,
      color: AppColors.listenerBackButtonBorder,
    );
  }
}
