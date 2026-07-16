import '../../../../../core/utils/app_exports.dart';

class ArtistSignupHeader extends StatelessWidget {
  const ArtistSignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset(
            "assets/icons/png/artist_signup_music_note_icn.png",
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.music_note,
              color: AppColors.listenerYellow,
              size: 48.sp,
            ),
          ),
          16.ph,
          Text(
            "Create Account",
            style: TextStyle(
              fontFamily: 'Roboto',
              color: AppColors.primaryWhite,
              fontSize: 30.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          6.ph,
          Text(
            "Join as an Artist",
            style: TextStyle(
              fontFamily: 'Roboto',
              color: AppColors.santagrey,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
