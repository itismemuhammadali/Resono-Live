import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import '../controllers/artist_performances_controller.dart';
import '../widgets/schedule_app_bar.dart';
import '../widgets/review_card.dart';

class ScheduleReviewView extends ConsumerStatefulWidget {
  const ScheduleReviewView({super.key});

  @override
  ConsumerState<ScheduleReviewView> createState() => _ScheduleReviewViewState();
}

class _ScheduleReviewViewState extends ConsumerState<ScheduleReviewView> {
  Future<void> _scheduleLiveSession() async {
    final controller = ref.read(artistPerformancesControllerProvider);
    final success = await controller.scheduleLiveSession();
    if (mounted) {
      if (success) {
        AppRouterGo.push(artistScheduleSuccessView);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to schedule live session. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              ScheduleAppBar(currentStep: 5, totalSteps: controller.totalSteps),
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
                        'Review & Schedule',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.primaryWhite,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      20.ph,
                      ReviewCard(controller: controller),
                      16.ph,
                      PrimaryElevatedButton(
                        onTap: () => _scheduleLiveSession(),
                        text: controller.isScheduling ? 'Scheduling...' : 'Schedule Live Session',
                        enabled: !controller.isScheduling,
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
