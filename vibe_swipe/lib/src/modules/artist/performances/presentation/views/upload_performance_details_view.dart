import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/modules/artist/register/presentation/widgets/artist_labeled_field.dart';
import '../controllers/artist_performances_controller.dart';
import '../widgets/schedule_app_bar.dart';

class UploadPerformanceDetailsView extends ConsumerWidget {
  const UploadPerformanceDetailsView({super.key});

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
                currentStep: 3,
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
                        'Performance Details',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.primaryWhite,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      20.ph,
                      ArtistLabeledField(
                        label: 'Performance Title',
                        hintText: 'Enter performance title',
                        controller: controller.uploadPerformanceTitleController,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) => ref
                            .read(artistPerformancesControllerProvider)
                            .onPerformanceDetailsFieldChanged(),
                      ),
                      20.ph,
                      ArtistLabeledField(
                        label: 'Description',
                        hintText: 'Enter performance title',
                        controller:
                            controller.uploadPerformanceDescriptionController,
                        maxLines: 9,
                        minLines: 8,
                        textInputType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        isLast: true,
                        onChanged: (_) => ref
                            .read(artistPerformancesControllerProvider)
                            .onPerformanceDetailsFieldChanged(),
                      ),
                      32.ph,
                      PrimaryElevatedButton(
                        onTap: () => AppRouterGo.push(artistUploadCategoryTagsView),
                        text: 'Continue',
                        enabled: controller.canContinuePerformanceDetails,
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
