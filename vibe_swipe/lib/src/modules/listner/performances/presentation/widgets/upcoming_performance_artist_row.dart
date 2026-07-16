import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/performance_upcoming_entity.dart';

class UpcomingPerformanceArtistRow extends StatelessWidget {
  const UpcomingPerformanceArtistRow({super.key, required this.performance});

  final PerformanceUpcomingEntity performance;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NetworkSnap(
          imageUrl: performance.artistImageUrl,
          width: 48.w,
          height: 48.w,
          fit: BoxFit.cover,
          borderRadiusGeometry: BorderRadius.circular(24.w),
          errorWidget: (_, __, ___) => Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF8C42), Color(0xFFFF6B35)],
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              color: AppColors.primaryWhite,
              size: 18.sp,
            ),
          ),
        ),
        10.pw,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              performance.artist,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryWhite,
              ),
            ),
            Text(
              performance.genre,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryWhite.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
