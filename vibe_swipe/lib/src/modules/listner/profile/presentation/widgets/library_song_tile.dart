import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../data/dtos/library_song_dto.dart';

class LibrarySongTile extends StatelessWidget {
  const LibrarySongTile({
    super.key,
    required this.song,
    required this.isHistory,
  });

  final LibrarySongDto song;
  final bool isHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: 16.circular,
        border: Border.all(color: AppColors.listenerChipBorder, width: 1.w),
      ),
      child: Row(
        children: [
          _AlbumArt(colors: song.coverColors, coverUrl: song.coverUrl),
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
                4.ph,
                Text(
                  song.artist,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.huegrey,
                    fontFamily: 'Roboto',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                4.ph,
                Text(
                  song.genre,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.listenerYellow,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          8.pw,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => AppRouterGo.push(
                  listenerSongDetailView,
                  extra: {'song': song, 'isHistory': isHistory},
                ),
                child: _ActionIcon(asset: AppAssetsPng.performancesPlayIcn),
              ),
              25.pw,
              // _ActionIcon(asset: AppAssetsPng.historyOpenIcn),
              // 25.pw,
              _ActionIcon(asset: AppAssetsPng.historyDltIcn),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlbumArt extends StatelessWidget {
  const _AlbumArt({required this.colors, this.coverUrl});

  final List<Color> colors;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return NetworkSnap(
      imageUrl: coverUrl,
      width: 64.w,
      height: 64.w,
      fit: BoxFit.cover,
      borderRadiusGeometry: 12.circular,
      errorWidget: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: AppColors.primaryWhite.withValues(alpha: 0.6),
        size: 24.sp,
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(asset, width: 22.w, height: 22.w);
  }
}
