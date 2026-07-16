import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class SongGenreChip extends StatelessWidget {
  const SongGenreChip({super.key, required this.genre});

  final String genre;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.listenerYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.listenerYellow, width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(AppAssetsPng.songMusicIcn, width: 14.w, height: 14.w),
          5.pw,
          Text(
            genre,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.listenerYellow,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}
