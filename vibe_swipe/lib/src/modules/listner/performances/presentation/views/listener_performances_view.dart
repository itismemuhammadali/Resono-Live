import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/listener_performances_controller.dart';
import '../widgets/performances_featured_section.dart';
import '../widgets/performances_upcoming_section.dart';
import '../widgets/performances_trending_section.dart';

class ListenerPerformancesView extends ConsumerWidget {
  const ListenerPerformancesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(listenerPerformancesControllerProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20.r),
                        bottomLeft: Radius.circular(20.r),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.snowWhite.withValues(alpha: 0.4),
                          width: 1.w,
                        ),
                      ),
                    ),
                    child: Text(
                      'Performances',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryWhite,
                      ),
                    ),
                  ),
                  if (controller.isLoading)
                    Padding(
                      padding: EdgeInsets.only(top: 80.h),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.listenerYellow,
                        ),
                      ),
                    )
                  else if (controller.upcomingPerformances.isEmpty &&
                      controller.trendingPerformances.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 80.h),
                      child: Center(
                        child: Text(
                          'No performances available yet',
                          style: TextStyle(
                            color: AppColors.huegrey,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          24.ph,
                          PerformancesFeaturedSection(
                            featured: controller.featured,
                          ),
                          if (controller.upcomingPerformances.isNotEmpty) ...[
                            24.ph,
                            PerformancesUpcomingSection(
                              performances: controller.upcomingPerformances,
                            ),
                          ],
                          if (controller.trendingPerformances.isNotEmpty) ...[
                            24.ph,
                            PerformancesTrendingSection(
                              performances: controller.trendingPerformances,
                            ),
                          ],
                          32.ph,
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
