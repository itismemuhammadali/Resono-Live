import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import '../../domain/entities/performance_entity.dart';
import '../widgets/detail_row.dart';

class ArtistSessionEndedView extends StatelessWidget {
  const ArtistSessionEndedView({
    super.key,
    required this.item,
    required this.duration,
  });

  final PerformanceEntity item;
  final String duration;

  String _formatDate(DateTime d) {
    final h = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
    final m = d.minute.toString().padLeft(2, '0');
    final s = d.second.toString().padLeft(2, '0');
    final period = d.hour < 12 ? 'AM' : 'PM';
    return '${d.month}/${d.day}/${d.year}, $h:$m:$s $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          NetworkSnap(
            imageUrl: item.thumbnailUrl,
            width: 1.sw,
            height: 1.sh,
            fit: BoxFit.cover,
            radius: 0,
            errorWidget: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A2040), Color(0xFF0D121B)],
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.listenerDashboardBg.withValues(alpha: 0.10),
                  AppColors.listenerDashboardBg.withValues(alpha: 0.45),
                  AppColors.listenerDashboardBg.withValues(alpha: 0.88),
                  AppColors.listenerDashboardBg.withValues(alpha: 0.98),
                ],
                stops: const [0.0, 0.35, 0.60, 1.0],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [const CircularBackButton(), _LiveBadge()],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black50,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              color: AppColors.primaryWhite,
                              size: 18.sp,
                            ),
                            8.pw,
                            FutureBuilder<int>(
                              future: locator<FirestoreService>().getPerformanceUniqueViewerCount(item.id),
                              builder: (context, snapshot) {
                                final count = snapshot.data ?? item.viewCount;
                                return Text(
                                  '$count',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.primaryWhite,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      20.pw,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black50,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          duration,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primaryWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                16.ph,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _SessionDetailsCard(
                    category: item.category ?? '—',
                    scheduled: _formatDate(item.date),
                  ),
                ),
                16.ph,
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
                  child: PrimaryElevatedButton(
                    onTap: () {
                      AppRouterGo.back();
                    },
                    text: 'End Session',
                    backgroundColor: AppColors.artistEndSessionRed,
                    textColor: AppColors.primaryWhite,
                    leadingWidget: Icon(
                      Icons.stop_circle_outlined,
                      color: AppColors.primaryWhite,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
      decoration: BoxDecoration(
        color: AppColors.artistLiveBadgeRed,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.h,
            height: 8.h,
            decoration: const BoxDecoration(
              color: AppColors.primaryWhite,
              shape: BoxShape.circle,
            ),
          ),
          8.pw,
          Text(
            'LIVE',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryWhite,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionDetailsCard extends StatelessWidget {
  const _SessionDetailsCard({required this.category, required this.scheduled});

  final String category;
  final String scheduled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border(
          top: BorderSide(
            color: AppColors.primaryWhite.withValues(alpha: 0.10),
            width: 1.09,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Details',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryWhite,
            ),
          ),
          16.ph,
          DetailRow(label: 'Category', value: category),
          16.ph,
          DetailRow(label: 'Scheduled', value: scheduled),
          16.ph,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.huegrey,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.artistLiveBadgeRed.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  'Live',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.artistLiveBadgeRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
