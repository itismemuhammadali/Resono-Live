import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import '../controllers/artist_performances_controller.dart';
import '../widgets/schedule_app_bar.dart';
import '../widgets/upload_review_card.dart';

class UploadReviewView extends ConsumerStatefulWidget {
  const UploadReviewView({super.key});

  @override
  ConsumerState<UploadReviewView> createState() => _UploadReviewViewState();
}

class _UploadReviewViewState extends ConsumerState<UploadReviewView> {
  Future<void> _publishPerformance() async {
    final controller = ref.read(artistPerformancesControllerProvider);
    final success = await controller.publishPerformance();
    if (mounted) {
      if (success) {
        AppRouterGo.push(artistUploadSuccessView);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to publish performance. Please try again.')),
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
              ScheduleAppBar(
                currentStep: 5,
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
                        'Review & Schedule',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.primaryWhite,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      20.ph,
                      UploadReviewCard(controller: controller),
                      16.ph,
                      PrimaryElevatedButton(
                        onTap: () => _publishPerformance(),
                        text: controller.isPublishing ? 'Publishing...' : 'Publish Performance',
                        enabled: !controller.isPublishing,
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
