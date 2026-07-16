import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import '../controllers/artist_profile_controller.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(artistProfileControllerProvider);
    return PrimaryElevatedButton(
      onTap: notifier.onLogout,
      text: 'Logout',
      textColor: AppColors.deleteRed,
      leadingWidget: Container(
        width: 36.w,
        height: 36.w,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.deleteRed.withValues(alpha: 0.2),
          borderRadius: 12.circular,
        ),
        child: FittedBox(
          child: Icon(
            Icons.logout,
            color: AppColors.deleteRed,
          ),
        ),
      ),
      buttonStyle: ElevatedButton.styleFrom(
        backgroundColor: AppColors.deleteRed.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: 16.circular,
          side: BorderSide(
            color: AppColors.deleteRed,
            width: 1.09.w,
          ),
        ),
        elevation: 0,
      ),
    );
  }
}
