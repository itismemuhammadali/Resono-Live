import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class ArtistCreatePostFieldLabel extends StatelessWidget {
  const ArtistCreatePostFieldLabel({
    super.key,
    required this.text,
    this.isRequired = true,
  });

  final String text;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.coolGray,
      ),
    );
  }
}
