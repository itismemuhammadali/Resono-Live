import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../data/dtos/artist_dto.dart';

class ArtistTopSongsSection extends StatelessWidget {
  const ArtistTopSongsSection({super.key, required this.songs});

  final List<ArtistTopSongDto> songs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Songs',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryWhite,
            fontFamily: 'Roboto',
          ),
        ),
        20.ph,
        ListView.separated(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: songs.length,
          separatorBuilder: (_, __) => 10.ph,
          itemBuilder: (_, index) => _TopSongTile(song: songs[index]),
        ),
      ],
    );
  }
}

class _TopSongTile extends StatelessWidget {
  const _TopSongTile({required this.song});

  final ArtistTopSongDto song;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.listenerChipBorder, width: 1.w),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          _SongCoverThumbnail(song: song),
          16.pw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryWhite,
                    fontFamily: 'Roboto',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                5.ph,
                Text(
                  song.playsCount,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.coolGray,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          12.pw,
          Icon(
            Icons.play_arrow_outlined,
            color: AppColors.listenerYellow,
            size: 40.sp,
          ),
        ],
      ),
    );
  }
}

class _SongCoverThumbnail extends StatelessWidget {
  const _SongCoverThumbnail({required this.song});

  final ArtistTopSongDto song;

  @override
  Widget build(BuildContext context) {
    return NetworkSnap(
      imageUrl: song.coverUrl,
      width: 60.w,
      height: 60.w,
      fit: BoxFit.cover,
      radius: 12,
      errorWidget: (_, __, ___) => _ThumbnailFallback(colors: song.coverColors),
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback({required this.colors});

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
          color: AppColors.primaryWhite.withValues(alpha: 0.5),
          size: 24.sp,
        ),
      ),
    );
  }
}
