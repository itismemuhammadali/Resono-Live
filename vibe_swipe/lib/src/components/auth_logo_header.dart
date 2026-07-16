import '../core/utils/app_exports.dart';

class AuthLogoHeader extends StatelessWidget {
  const AuthLogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          "assets/icons/png/music_note_icn.png",
          height: 32.h,
          width: 32.w,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.music_note,
            color: AppColors.listenerYellow,
            size: 32.sp,
          ),
        ),
        12.pw,
        Text(
          "Vibe Swipe",
          style: TextStyle(
            fontFamily: 'Roboto',
            color: AppColors.primaryWhite,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
