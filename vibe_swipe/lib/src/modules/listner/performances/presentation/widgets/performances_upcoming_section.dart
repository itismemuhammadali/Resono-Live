import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/performance_upcoming_entity.dart';
import 'performances_section_title.dart';

class PerformancesUpcomingSection extends StatelessWidget {
  const PerformancesUpcomingSection({super.key, required this.performances});

  final List<PerformanceUpcomingEntity> performances;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PerformancesSectionTitle(
          image: 'assets/icons/png/performance_clock_icn.png',
          title: _getSectionTitle(performances),
        ),
        16.ph,
        ...List.generate(performances.length, (i) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: i < performances.length - 1 ? 12.h : 0,
            ),
            child: _UpcomingCard(performance: performances[i]),
          );
        }),
      ],
    );
  }

  String _getSectionTitle(List<PerformanceUpcomingEntity> performances) {
    final hasLive = performances.any((p) => p.isLive);
    final hasRecorded = performances.any((p) => p.isRecorded);
    if (hasLive && hasRecorded) return 'Performances';
    if (hasRecorded) return 'Recorded';
    return 'Upcoming Live';
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.performance});

  final PerformanceUpcomingEntity performance;

  void _onTap() {
    AppRouterGo.push(
      listenerUpcomingPerformanceDetailView,
      extra: performance,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRecorded = performance.isRecorded;

    return GestureDetector(
      onTap: _onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFF121821),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isRecorded
                ? const Color(0xFF4A90A4).withValues(alpha: 0.3)
                : const Color(0xFF1F2937),
            width: 1.09.w,
          ),
        ),
        child: Row(
          children: [
            Stack(
              alignment: AlignmentGeometry.center,
              children: [
                NetworkSnap(
                  imageUrl: performance.thumbnailUrl,
                  width: 68.w,
                  height: 68.h,
                  fit: BoxFit.cover,
                  radius: 8,
                  errorWidget: (_, __, ___) => Container(
                    width: 68.w,
                    height: 68.h,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFB84A00), Color(0xFF7B2D00)],
                      ),
                    ),
                  ),
                ),
                Image.asset('assets/icons/png/performances_play_icn.png'),
              ],
            ),
            16.pw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          performance.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryWhite,
                          ),
                        ),
                      ),
                      8.pw,
                      _PerformanceBadge(type: performance.type),
                    ],
                  ),
                  4.ph,
                  Text(
                    performance.artist,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryWhite.withValues(alpha: 0.55),
                    ),
                  ),
                  4.ph,
                  Text(
                    performance.time,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isRecorded
                          ? const Color(0xFF4A90A4)
                          : AppColors.listenerYellow,
                    ),
                  ),
                ],
              ),
            ),
            16.pw,
            NetworkSnap(
              imageUrl: performance.artistImageUrl,
              width: 38.w,
              height: 38.h,
              fit: BoxFit.cover,
              borderRadiusGeometry: BorderRadius.circular(19.w),
              errorWidget: (_, __, ___) => Container(
                width: 38.w,
                height: 38.h,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF8C42), Color(0xFFFF6B35)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceBadge extends StatelessWidget {
  const _PerformanceBadge({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final isRecorded = type == 'recorded';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isRecorded
            ? const Color(0xFF4A90A4).withValues(alpha: 0.2)
            : AppColors.listenerYellow.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        isRecorded ? 'Recorded' : 'Upcoming',
        style: TextStyle(
          fontFamily: 'Roboto',
          color: isRecorded ? const Color(0xFF4A90A4) : AppColors.listenerYellow,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
