import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';

class InitialPermissionSheet extends StatelessWidget {
  const InitialPermissionSheet({super.key});

  static Future<void> show(BuildContext context) async {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: const Color(0xFF161B26),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => const InitialPermissionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            20.ph,
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.listenerYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.security,
                    color: AppColors.listenerYellow,
                    size: 24.sp,
                  ),
                ),
                12.pw,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Permissions Setup',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryWhite,
                        ),
                      ),
                      4.ph,
                      Text(
                        'Allow access for the full music experience',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.santagrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            20.ph,
            _buildPermissionItem(
              icon: Icons.camera_alt_outlined,
              title: 'Camera',
              subtitle: 'Capture profile photos and broadcast live performances',
            ),
            12.ph,
            _buildPermissionItem(
              icon: Icons.mic_none_outlined,
              title: 'Microphone',
              subtitle: 'Stream live audio and record music tracks',
            ),
            12.ph,
            _buildPermissionItem(
              icon: Icons.photo_library_outlined,
              title: Platform.isIOS ? 'Photo Library' : 'Storage / Media',
              subtitle: 'Upload custom cover art and profile pictures',
            ),
            12.ph,
            _buildPermissionItem(
              icon: Icons.notifications_none_outlined,
              title: 'Notifications',
              subtitle: 'Get alerts when your favorite artists go live',
            ),
            24.ph,
            PrimaryElevatedButton(
              onTap: () async {
                Navigator.of(context).pop();
                await locator<PermissionService>().requestInitialPermissions();
              },
              text: 'Continue',
              backgroundColor: AppColors.listenerYellow,
              textColor: AppColors.primaryblack,
              radius: 12,
            ),
            8.ph,
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await locator<PermissionService>().markInitialPermissionsRequested();
              },
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  color: AppColors.santagrey,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2433),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.listenerYellow, size: 20.sp),
          ),
          12.pw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryWhite,
                  ),
                ),
                2.ph,
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.santagrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
