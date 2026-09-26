import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/modules/artist/dashboard/presentation/controllers/artist_dashboard_controller.dart';

class MenuSection extends ConsumerWidget {
  const MenuSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.read(artistDashboardControllerProvider);
    final items = [
      _MenuItem(
        asset: 'assets/icons/png/artist_profile_edit_icn.png',
        label: 'Edit Profile',
        onTap: () => AppRouterGo.push(artistEditProfileView),
      ),
      _MenuItem(
        asset: 'assets/icons/png/artist_profile_my_tracks_icn.png',
        label: 'My Tracks',
        onTap: () => dashboard.onTabTapped(1),
      ),
      _MenuItem(
        asset: 'assets/icons/png/artist_profile_analytics_icn.png',
        label: 'Analytics',
        onTap: () => dashboard.onTabTapped(3),
      ),
      _MenuItem(
        emoji: '💰',
        label: 'Earnings',
        onTap: () => AppRouterGo.push(artistEarningsView),
      ),
      _MenuItem(
        asset: 'assets/icons/png/artist_profile_notification_icn.png',
        label: 'Notification Settings',
        onTap: () => AppRouterGo.push(artistNotificationSettingsView),
      ),
      _MenuItem(
        asset: 'assets/icons/png/artist_profile_privacy_icn.png',
        label: 'Privacy Settings',
        onTap: () => AppRouterGo.push(artistPrivacySettingsView),
      ),
      _MenuItem(
        emoji: '⚖️',
        label: 'Terms & Policies',
        onTap: () => AppRouterGo.push(termsAndPoliciesView, extra: {'isArtist': true}),
      ),
      _MenuItem(
        asset: 'assets/icons/png/artist_profile_help_and_support_icn.png',
        label: 'Help & Support',
        onTap: () => AppRouterGo.push(artistHelpSupportView),
      ),
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _MenuItemTile(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _MenuItem {
  const _MenuItem({this.asset, this.emoji, required this.label, this.onTap});
  final String? asset;
  final String? emoji;
  final String label;
  final VoidCallback? onTap;
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({required this.item});

  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.listenerChipBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.primaryWhite.withValues(alpha: 0.10),
            width: 1.09,
          ),
        ),
        child: Row(
          children: [
            if (item.emoji != null)
              SizedBox(
                width: 24.w,
                height: 24.h,
                child: Center(
                  child: Text(
                    item.emoji!,
                    style: TextStyle(
                      fontSize: 20.sp,
                    ),
                  ),
                ),
              )
            else if (item.asset != null)
              Image.asset(item.asset!),
            16.pw,
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryWhite,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.huegrey,
              size: 26.sp,
            ),
          ],
        ),
      ),
    );
  }
}
