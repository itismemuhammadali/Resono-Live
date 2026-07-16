import 'package:vibe_swipe/src/components/auth_logo_header.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          const AuthLogoHeader(),
          const Spacer(),
          GestureDetector(
            onTap: onSearchTap,
            child: Image.asset("assets/icons/png/home_search_button_icn.png"),
          ),
        ],
      ),
    );
  }
}
