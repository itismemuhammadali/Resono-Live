import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import '../../data/dtos/library_song_dto.dart';
import '../../data/dtos/artist_dto.dart';
import '../widgets/song_detail_hero_section.dart';
import '../widgets/song_genre_chip.dart';
import '../widgets/song_info_grid.dart';

class LibrarySongDetailView extends StatelessWidget {
  const LibrarySongDetailView({
    super.key,
    required this.song,
    required this.isHistory,
  });

  final LibrarySongDto song;
  final bool isHistory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SongDetailHeroSection(song: song),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SongGenreChip(genre: song.genre),
                  10.ph,
                  Text(
                    song.title,
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryWhite,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  6.ph,
                  Text(
                    song.artist,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.huegrey,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  20.ph,
                  SongInfoGrid(song: song),
                  20.ph,
                  PrimaryElevatedButton(
                    onTap: () {},
                    text: isHistory
                        ? 'Remove from History'
                        : 'Remove from Saved',
                    leadingWidget: Image.asset(
                      isHistory
                          ? AppAssetsPng.historyDltIcn
                          : AppAssetsPng.homeBookmarkIcn,
                      color: isHistory ? null : AppColors.listenerYellow,
                      width: 17.w,
                      height: 17.w,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryWhite,
                      fontFamily: 'Roboto',
                    ),
                    buttonStyle: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.listenerChipBg,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        side: BorderSide(
                          color: AppColors.listenerChipBorder,
                          width: 1.w,
                        ),
                      ),
                    ),
                  ),
                  12.ph,
                  PrimaryElevatedButton(
                    onTap: () {
                      AppRouterGo.push(
                        artistProfileView,
                        extra: ArtistProfileArgs(
                          artistId: song.id,
                          artistName: song.artist,
                        ),
                      );
                    },
                    text: 'Visit Artist Profile',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryWhite,
                      fontFamily: 'Roboto',
                    ),
                    buttonStyle: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.listenerChipBg,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        side: BorderSide(
                          color: AppColors.listenerChipBorder,
                          width: 1.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
