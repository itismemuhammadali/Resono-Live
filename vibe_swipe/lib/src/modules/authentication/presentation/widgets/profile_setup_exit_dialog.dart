import '../../../../core/utils/app_exports.dart';
import '../../../../components/primary_elevated_button.dart';

class ProfileSetupExitDialog extends StatelessWidget {
  final bool isArtist;

  const ProfileSetupExitDialog({
    super.key,
    required this.isArtist,
  });

  static Future<bool> show(BuildContext context, {required bool isArtist}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => ProfileSetupExitDialog(isArtist: isArtist),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: const Color(0xFF14141A),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: AppColors.listenerChipBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.listenerYellow.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.listenerYellow.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 32.sp,
                color: AppColors.listenerYellow,
              ),
            ),
            20.ph,
            Text(
              "Complete Your Profile",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryWhite,
              ),
              textAlign: TextAlign.center,
            ),
            12.ph,
            Text(
              isArtist
                  ? "Setting up your artist profile is required before sharing music and going live. If you exit now, you'll need to finish setup the next time you sign in."
                  : "Setting up your profile is required before exploring and discovering music. If you exit now, you'll need to finish setup the next time you sign in.",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14.sp,
                color: AppColors.santagrey,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            24.ph,
            PrimaryElevatedButton(
              onTap: () => Navigator.of(context).pop(false),
              text: "Continue Setup",
              backgroundColor: AppColors.listenerYellow,
              textColor: AppColors.primaryblack,
              radius: 12,
            ),
            12.ph,
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Log Out & Exit",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[300],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
