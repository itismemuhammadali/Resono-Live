import 'package:flutter/cupertino.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../widgets/privacy_settings_card.dart';
import '../widgets/artist_privacy_info_card.dart';

class ArtistPrivacySettingsView extends StatelessWidget {
  const ArtistPrivacySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
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
              const ArtistPageHeader(title: 'Privacy Settings'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    top: 0.h,
                    bottom: 16.h,
                  ),
                  child: Column(
                    children: [
                      const PrivacySettingsCard(),
                      24.ph,
                      const ArtistPrivacyInfoCard(),
                      24.ph,
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deleteRed.withValues(alpha: 0.15),
                            side: BorderSide(color: AppColors.deleteRed, width: 1),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          onPressed: () {
                            showCupertinoDialog(
                              context: context,
                              builder: (ctx) => CupertinoAlertDialog(
                                title: const Text('Delete Account'),
                                content: const Text(
                                  'Are you sure you want to delete your account? This action is permanent and cannot be undone.',
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text('Cancel'),
                                    onPressed: () => Navigator.pop(ctx),
                                  ),
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    child: const Text('Delete Account'),
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      await AuthHandler.ref.deleteAccount();
                                      if (context.mounted) {
                                        AppRouterGo.pushReplacement(loginView);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_forever_outlined, color: AppColors.deleteRed, size: 20.sp),
                              8.pw,
                              Text(
                                'Delete Account',
                                style: AppTextTheme.titleMediumBlack16?.copyWith(
                                  color: AppColors.deleteRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
