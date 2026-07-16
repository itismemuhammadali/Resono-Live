import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../data/dtos/library_song_dto.dart';

class SongInfoGrid extends StatelessWidget {
  const SongInfoGrid({super.key, required this.song});

  final LibrarySongDto song;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _InfoCard(label: 'Album', value: song.album ?? '—')),
            8.pw,
            Expanded(
              child: _InfoCard(label: 'Duration', value: song.duration ?? '—'),
            ),
          ],
        ),
        8.ph,
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                label: 'Release Year',
                value: song.releaseYear ?? '—',
              ),
            ),
            8.pw,
            Expanded(child: _InfoCard(label: 'Genre', value: song.genre)),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.listenerChipBorder, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.huegrey,
              fontFamily: 'Roboto',
            ),
          ),
          6.ph,
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryWhite,
              fontFamily: 'Roboto',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
