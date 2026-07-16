import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import '../controllers/artist_performances_controller.dart';
import '../widgets/schedule_app_bar.dart';
import '../widgets/category_grid.dart';
import '../widgets/tag_input_row.dart';
import '../widgets/tag_chip_list.dart';
import '../widgets/link_to_song_dropdown.dart';

class UploadCategoryTagsView extends ConsumerWidget {
  const UploadCategoryTagsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(artistPerformancesControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/png/app_background_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScheduleAppBar(
                currentStep: 4,
                totalSteps: controller.totalSteps,
                title: 'Upload Performance',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category & Tags',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.primaryWhite,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      20.ph,
                      Text(
                        'Category',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.primaryWhite,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      12.ph,
                      CategoryGrid(controller: controller, ref: ref),
                      20.ph,
                      Text(
                        'Tags',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.primaryWhite,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      12.ph,
                      TagInputRow(controller: controller, ref: ref),
                      if (controller.tags.isNotEmpty) ...[
                        12.ph,
                        TagChipList(controller: controller, ref: ref),
                      ],
                      24.ph,
                      Text(
                        'Link to Song (Optional)',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.primaryWhite,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      12.ph,
                      LinkToSongDropdown(controller: controller, ref: ref),
                      32.ph,
                      PrimaryElevatedButton(
                        onTap: () => AppRouterGo.push(artistUploadReviewView),
                        text: 'Continue',
                        enabled: controller.canContinueCategory,
                        radius: 14,
                        buttonStyle: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: 14.circular,
                          ),
                          backgroundColor: AppColors.listenerActiveTab,
                          disabledBackgroundColor: AppColors.listenerActiveTab
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      20.ph,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
