import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/modules/authentication/presentation/widgets/auth_back_button.dart';

class ArtistPageHeader extends StatelessWidget {
  const ArtistPageHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: 16.h,
      ),
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(color: AppColors.listenerChipBg, width: 1),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthBackButton(),
          12.ph,
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Roboto',
              color: AppColors.primaryWhite,
              fontSize: 24.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
