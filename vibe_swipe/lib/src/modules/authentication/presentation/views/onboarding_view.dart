import '../../../../core/utils/app_exports.dart';
import '../../../../components/primary_elevated_button.dart';
import '../controllers/authentication_controller.dart';
import '../widgets/onboarding_dot.dart';
import '../widgets/onboarding_page_content.dart';

class OnboardingView extends HookConsumerWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(authControllerProvider);
    final pageController = usePageController();

    void nextPage() {
      if (controller.currentPage < controller.onboardingData.length - 1) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        AppRouterGo.pushReplacement(loginView);
      }
    }

    return Scaffold(
      backgroundColor: const Color(
        0xFF11151E,
      ), // Dark background matching images
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            onPageChanged: (value) {
              ref.read(authControllerProvider).setPage(value);
            },
            itemCount: controller.onboardingData.length,
            itemBuilder: (context, index) => OnboardingPageContent(
              title: controller.onboardingData[index]['title']!,
              subtitle: controller.onboardingData[index]['subtitle']!,
              image: controller.onboardingData[index]['image'],
              feature: controller.onboardingData[index]['feature'],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.onboardingData.length,
                        (index) => OnboardingDot(
                          index: index,
                          currentPage: controller.currentPage,
                        ),
                      ),
                    ),
                    20.ph,
                    PrimaryElevatedButton(
                      onTap: nextPage,
                      text: controller.currentPage ==
                              controller.onboardingData.length - 1
                          ? "Get Started"
                          : "Next",
                    ),
                    16.ph, // Bottom padding inside SafeArea
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
