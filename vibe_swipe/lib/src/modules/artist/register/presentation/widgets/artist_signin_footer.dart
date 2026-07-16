import '../../../../../core/utils/app_exports.dart';

class ArtistSigninFooter extends StatelessWidget {
  const ArtistSigninFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => AppRouterGo.push(loginView),
        child: RichText(
          text: TextSpan(
            style: TextStyle(fontFamily: 'Roboto', fontSize: 14.sp),
            children: const [
              TextSpan(
                text: "Already have an account?  ",
                style: TextStyle(
                  color: AppColors.santagrey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: "Sign In",
                style: TextStyle(
                  color: AppColors.listenerYellow,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
