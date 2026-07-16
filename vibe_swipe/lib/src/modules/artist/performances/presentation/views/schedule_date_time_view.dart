import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/modules/artist/register/presentation/widgets/artist_labeled_field.dart';
import '../controllers/artist_performances_controller.dart';
import '../widgets/schedule_app_bar.dart';

class ScheduleDateTimeView extends ConsumerWidget {
  const ScheduleDateTimeView({super.key});

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
              ScheduleAppBar(currentStep: 3, totalSteps: controller.totalSteps),
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
                        'Schedule Date & Time',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.primaryWhite,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      20.ph,
                      ArtistLabeledField(
                        label: 'Date',
                        hintText: 'MM/DD/YYYY',
                        controller: controller.dateController,
                        readOnly: true,
                        prefixWidget: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.gray500,
                            size: 18.sp,
                          ),
                        ),
                        onTap: () => ref
                            .read(artistPerformancesControllerProvider)
                            .pickDate(context),
                      ),
                      20.ph,
                      ArtistLabeledField(
                        label: 'Time',
                        hintText: '--:--',
                        controller: controller.timeController,
                        readOnly: true,
                        isLast: true,
                        prefixWidget: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Icon(
                            Icons.access_time,
                            color: AppColors.gray500,
                            size: 18.sp,
                          ),
                        ),
                        onTap: () => ref
                            .read(artistPerformancesControllerProvider)
                            .pickTime(context),
                      ),
                      32.ph,
                      PrimaryElevatedButton(
                        onTap: () => AppRouterGo.push(
                          artistScheduleCategoryTagsView,
                        ),
                        text: 'Continue',
                        enabled: controller.canContinueDateTime,
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
