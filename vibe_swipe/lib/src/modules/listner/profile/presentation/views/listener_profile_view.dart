import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/core/constants/app_constants.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import '../controllers/listener_profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/profile_menu_section.dart';

class ListenerProfileView extends ConsumerWidget {
  const ListenerProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(listenerProfileControllerProvider.notifier);
    final controller = ref.watch(listenerProfileControllerProvider);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(20.r),
                  bottomLeft: Radius.circular(20.r),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.snowWhite.withValues(alpha: 0.4),
                    width: 1.w,
                  ),
                ),
              ),
              child: Text(
                'Profile',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryWhite,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  24.ph,
                  ProfileHeader(
                    name: controller.name,
                    username: controller.username,
                    profileImageUrl: controller.profileImageUrl,
                  ),
                  28.ph,
                  ProfileStatsRow(
                    likedCount: controller.likedCount,
                    savedCount: controller.savedCount,
                    genreCount: controller.genreCount,
                  ),
                  16.ph,
                  Divider(color: AppColors.listenerBackButtonBorder),
                  16.ph,
                  const ProfileMenuSection(),
                  28.ph,
                  PrimaryElevatedButton(
                    onTap: notifier.onLogout,
                    text: 'Logout',
                    textColor: const Color(0xFFEF4444),
                    leadingWidget: Container(
                      width: 36.w,
                      height: 36.w,
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                        borderRadius: 12.circular,
                      ),
                      child: FittedBox(
                        child: Icon(
                          Icons.logout,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                    buttonStyle: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFEF4444,
                      ).withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: 16.circular,
                        side: BorderSide(
                          color: const Color(0xFFEF4444),
                          width: 1.09.w,
                        ),
                      ),
                      elevation: 0,
                    ),
                  ),
                  16.ph,
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
          ],
        ),
      ),
    );
  }
}
