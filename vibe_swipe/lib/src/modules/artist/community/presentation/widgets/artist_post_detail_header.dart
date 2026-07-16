import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/modules/authentication/presentation/widgets/auth_back_button.dart';

class ArtistPostDetailHeader extends StatelessWidget {
  const ArtistPostDetailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/png/app_background_image.png'),
          fit: BoxFit.cover,
        ),
        border: const Border(
          bottom: BorderSide(color: AppColors.listenerChipBg, width: 1),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: 16.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthBackButton(),
              12.ph,
              Text(
                'Post',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.primaryWhite,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
