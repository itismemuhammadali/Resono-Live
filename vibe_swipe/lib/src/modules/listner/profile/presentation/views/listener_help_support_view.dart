import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/core/constants/app_constants.dart';
import '../controllers/listener_profile_controller.dart';
import '../widgets/privacy_info_card.dart';
import '../widgets/help_section_label.dart';
import '../widgets/email_support_tile.dart';
import '../widgets/faq_tile.dart';

class ListenerHelpSupportView extends ConsumerWidget {
  const ListenerHelpSupportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(listenerProfileControllerProvider);

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
            children: [
              const ListenerPageHeader(title: 'Help & Support'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      20.ph,
                      const HelpSectionLabel(label: 'Contact Us'),
                      16.ph,
                      const EmailSupportTile(),
                      12.ph,
                      GestureDetector(
                        onTap: () =>
                            AppRouterGo.push(listenerPrivacySettingsView),
                        child: const PrivacyInfoCard(),
                      ),
                      28.ph,
                      Divider(
                        color: AppColors.listenerBackButtonBorder,
                        thickness: 1.h,
                      ),
                      28.ph,
                      const HelpSectionLabel(
                        label: 'Frequently Asked Questions',
                      ),
                      16.ph,
                      if (controller.faqs.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Center(
                            child: Text(
                              'No FAQs available yet.',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.huegrey,
                              ),
                            ),
                          ),
                        )
                      else
                        ...List.generate(controller.faqs.length, (i) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom:
                                  i < controller.faqs.length - 1 ? 12.h : 0,
                            ),
                            child: FaqTile(item: controller.faqs[i]),
                          );
                        }),
                      40.ph,
                      Center(
                        child: Text(
                          AppConstants.appVersion,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.huegrey,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      24.ph,
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
