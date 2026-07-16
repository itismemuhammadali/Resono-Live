import '../../../../../core/utils/app_exports.dart';
import '../../../../../components/custom_textfield.dart';

class ArtistSocialLinks extends StatelessWidget {
  const ArtistSocialLinks({
    super.key,
    required this.onSpotifyChanged,
    required this.onYoutubeChanged,
    required this.onInstagramChanged,
    this.spotifyValidator,
    this.youtubeValidator,
    this.instagramValidator,
  });

  final void Function(String) onSpotifyChanged;
  final void Function(String) onYoutubeChanged;
  final void Function(String) onInstagramChanged;
  final String? Function(String?)? spotifyValidator;
  final String? Function(String?)? youtubeValidator;
  final String? Function(String?)? instagramValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Social Links",
          style: TextStyle(
            fontFamily: 'Roboto',
            color: AppColors.gray300,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        12.ph,
        _urlField(
          hintText: "Spotify URL",
          onChanged: onSpotifyChanged,
          validator: spotifyValidator,
        ),
        10.ph,
        _urlField(
          hintText: "YouTube URL",
          onChanged: onYoutubeChanged,
          validator: youtubeValidator,
        ),
        10.ph,
        _urlField(
          hintText: "Instagram URL",
          onChanged: onInstagramChanged,
          validator: instagramValidator,
          isLast: true,
        ),
      ],
    );
  }

  Widget _urlField({
    required String hintText,
    required void Function(String) onChanged,
    String? Function(String?)? validator,
    bool isLast = false,
  }) {
    return CustomTextField(
      hintText: hintText,
      isLast: isLast,
      onChanged: onChanged,
      validator: validator,
      textInputType: TextInputType.url,
      fillColor: AppColors.listenerChipBg,
      enableBorderColor: AppColors.listenerChipBorder,
      focusedBorderColor: AppColors.listenerYellow,
      cursorColor: AppColors.primaryWhite,
      textStyle: TextStyle(
        fontFamily: 'Roboto',
        color: AppColors.primaryWhite,
        fontSize: 14.sp,
      ),
      hintTextStyle: TextStyle(
        fontFamily: 'Roboto',
        color: AppColors.gray500,
        fontSize: 14.sp,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      inputBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
    );
  }
}
