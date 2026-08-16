import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/artist_dashboard_controller.dart';

class ArtistDashboardView extends ConsumerWidget {
  const ArtistDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(artistDashboardControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/png/app_background_image.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: controller.screens[controller.selectedIndex],
        ),
      ),
      bottomNavigationBar: _ArtistBottomBar(controller: controller),
    );
  }
}

class _ArtistBottomBar extends StatelessWidget {
  const _ArtistBottomBar({required this.controller});

  final ArtistDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.listenerDashboardBg,
        border: Border(
          top: BorderSide(color: AppColors.listenerNavBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80.h,
          child: Row(
            children: List.generate(controller.tabs.length, (i) {
              final selected = controller.isSelected(i);
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => controller.onTabTapped(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          selected
                              ? controller.tabs[i].selectedIcon
                              : controller.tabs[i].unselectedIcon,
                          width: 24.w,
                          height: 24.h,
                        ),
                        4.ph,
                        Text(
                          controller.tabs[i].label,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected
                                ? AppColors.listenerActiveTab
                                : AppColors.huegrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
