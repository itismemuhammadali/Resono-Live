import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../../home/presentation/widgets/artist_home_app_bar.dart';
import '../controllers/artist_profile_controller.dart';
import '../widgets/logout_button.dart';
import '../widgets/menu_section.dart';
import '../widgets/profile_card.dart';

class ArtistProfileView extends ConsumerWidget {
  const ArtistProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(artistProfileControllerProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArtistHomeAppBar(artistName: controller.artistName),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.ph,
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryWhite,
                    ),
                  ),
                  16.ph,
                  ProfileCard(controller: controller),
                  24.ph,
                  const MenuSection(),
                  24.ph,
                  const LogoutButton(),
                  32.ph,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
