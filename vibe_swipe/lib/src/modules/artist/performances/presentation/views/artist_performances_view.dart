import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/modules/artist/home/presentation/widgets/artist_home_app_bar.dart';
import '../controllers/artist_performances_controller.dart';
import '../widgets/performance_card.dart';
import '../widgets/performances_add_menu_button.dart';
import '../widgets/performances_empty_state.dart';
import '../widgets/performances_tab_bar.dart';

class ArtistPerformancesView extends ConsumerWidget {
  const ArtistPerformancesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(artistPerformancesControllerProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArtistHomeAppBar(artistName: controller.artistName),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Performances',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryWhite,
                      ),
                    ),
                    if (!controller.isCurrentTabEmpty)
                      const PerformancesAddMenuButton(),
                  ],
                ),
                16.ph,
                PerformancesTabBar(
                  tabs: controller.tabs,
                  selectedIndex: controller.selectedTabIndex,
                  onChanged: controller.onTabChanged,
                ),
              ],
            ),
          ),
          Expanded(
            child: controller.isCurrentTabEmpty
                ? PerformancesEmptyState(label: controller.emptyStateLabel)
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                    itemCount: controller.currentItems.length,
                    separatorBuilder: (_, __) => 10.ph,
                    itemBuilder: (_, index) =>
                        PerformanceCard(item: controller.currentItems[index]),
                  ),
          ),
          if (controller.isCurrentTabEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
              child: Column(
                children: [
                  PrimaryElevatedButton(
                    onTap: () =>
                        AppRouterGo.push(artistScheduleLiveSessionView),
                    text: 'Schedule Live Session',
                  ),
                  12.ph,
                  PrimaryElevatedButton(
                    onTap: () => AppRouterGo.push(artistUploadVideoView),
                    text: 'Upload Performance',
                    textColor: AppColors.primaryWhite,
                    buttonStyle: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.listenerChipBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        side: BorderSide(
                          color: AppColors.primaryWhite.withValues(alpha: 0.15),
                          width: 1,
                        ),
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
