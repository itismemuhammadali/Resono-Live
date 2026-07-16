import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class LivePerformanceArtistRow extends StatelessWidget {
  const LivePerformanceArtistRow({
    super.key,
    required this.artist,
    required this.genre,
    this.artistImageUrl = '',
  });

  final String artist;
  final String genre;
  final String artistImageUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.listenerAvatarBg,
          ),
          child: NetworkSnap(
            imageUrl: artistImageUrl,
            width: 52.w,
            height: 52.w,
            fit: BoxFit.cover,
            borderRadiusGeometry: BorderRadius.circular(26.w),
            errorWidget: (_, __, ___) => Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.listenerAvatarBg,
              ),
              child: Icon(
                Icons.person,
                size: 28.sp,
                color: AppColors.primaryWhite,
              ),
            ),
          ),
        ),
        14.pw,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              artist,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryWhite,
              ),
            ),
            6.ph,
            Container(
              width: 36.w,
              height: 3.h,
              decoration: BoxDecoration(
                color: AppColors.listenerActiveTab,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            6.ph,
            Text(
              genre,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryWhite.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
