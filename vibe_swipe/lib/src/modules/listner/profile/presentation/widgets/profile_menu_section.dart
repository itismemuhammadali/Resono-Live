import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({super.key});

  static final _items = [
    _MenuItem(
      label: 'Edit Profile',
      assetPath: 'assets/icons/png/profile_edit_profile_tab_icn.png',
      onTap: () => AppRouterGo.push(listenerEditProfileView),
    ),
    _MenuItem(
      icon: Icons.settings_outlined,
      label: 'Preferences',
      onTap: () => AppRouterGo.push(listenerPreferencesView),
    ),
    _MenuItem(
      icon: Icons.library_music_outlined,
      label: 'Library',
      onTap: () => AppRouterGo.push(listenerLibraryView),
    ),
    _MenuItem(
      label: 'Notifications',
      assetPath: 'assets/icons/png/profile_notification_tab_icn.png',
      onTap: () => AppRouterGo.push(listenerNotificationsView),
    ),
    _MenuItem(
      icon: Icons.shield_outlined,
      label: 'Privacy Settings',
      onTap: () => AppRouterGo.push(listenerPrivacySettingsView),
    ),
    _MenuItem(
      icon: Icons.gavel_outlined,
      label: 'Terms & Policies',
      onTap: () => AppRouterGo.push(termsAndPoliciesView, extra: {'isArtist': false}),
    ),
    _MenuItem(
      icon: Icons.help_outline,
      label: 'Help & Support',
      onTap: () => AppRouterGo.push(listenerHelpSupportView),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_items.length, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i < _items.length - 1 ? 12.h : 0),
          child: _MenuTile(item: _items[i]),
        );
      }),
    );
  }
}

class _MenuItem {
  const _MenuItem({this.icon, required this.label, this.assetPath, this.onTap});

  final IconData? icon;
  final String label;
  final String? assetPath;
  final VoidCallback? onTap;
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item});

  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: 16.circular,
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.listenerBackButtonBorder,
              borderRadius: 12.circular,
            ),
            child: item.assetPath != null
                ? Image.asset(
                    item.assetPath!,
                    color: AppColors.listenerActiveTab,
                    fit: BoxFit.contain,
                  )
                : FittedBox(
                    child: Icon(item.icon, color: AppColors.listenerActiveTab),
                  ),
          ),
          16.pw,
          Expanded(
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryWhite,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          Icon(Icons.chevron_right, size: 26.sp, color: AppColors.huegrey),
        ],
      ),
    ),
    );
  }
}
