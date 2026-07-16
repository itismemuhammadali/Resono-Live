import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import '../controllers/artist_performances_controller.dart';
import '../widgets/schedule_app_bar.dart';
import '../widgets/thumbnail_upload_box.dart';

class UploadThumbnailView extends ConsumerWidget {
  const UploadThumbnailView({super.key});

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
                currentStep: 2,
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
                        'Thumbnail',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.primaryWhite,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      20.ph,
                      ThumbnailUploadBox(
                        image: controller.uploadThumbnailImage,
                        imageBytes: controller.uploadThumbnailImageBytes,
                        onTap: () => ref
                            .read(artistPerformancesControllerProvider)
                            .pickThumbnailImage(context),
                      ),
                      32.ph,
                      PrimaryElevatedButton(
                        onTap: () => AppRouterGo.push(
                          artistUploadPerformanceDetailsView,
                        ),
                        text: 'Continue',
                        enabled: controller.uploadThumbnailImage != null,
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
