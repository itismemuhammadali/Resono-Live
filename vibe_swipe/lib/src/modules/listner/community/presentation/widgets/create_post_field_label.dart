import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class CreatePostFieldLabel extends StatelessWidget {
  const CreatePostFieldLabel({
    super.key,
    required this.text,
    this.isRequired = true,
  });

  final String text;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.coolGray,
        ),
        children: isRequired
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.listenerYellow,
                  ),
                ),
              ]
            : null,
      ),
    );
  }
}
