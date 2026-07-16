import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/artist_profile_controller.dart';
import 'privacy_row.dart';

class PrivacySettingsCard extends ConsumerWidget {
  const PrivacySettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(artistProfileControllerProvider);
    final notifier = ref.read(artistProfileControllerProvider.notifier);

    final rows = [
      _PrivacyRowData(
        icon: Icons.visibility_outlined,
        title: 'Public Profile',
        subtitle: 'Make your profile visible to everyone',
        value: controller.publicProfile,
        onChanged: notifier.togglePublicProfile,
      ),
      _PrivacyRowData(
        icon: Icons.email_outlined,
        title: 'Show Email Address',
        subtitle: 'Display your email on your public profile',
        value: controller.showEmailAddress,
        onChanged: notifier.toggleShowEmailAddress,
      ),
      _PrivacyRowData(
        icon: Icons.lock_outline,
        title: 'Show Social Links',
        subtitle: 'Display your social media links on profile',
        value: controller.showSocialLinks,
        onChanged: notifier.toggleShowSocialLinks,
      ),
      _PrivacyRowData(
        icon: Icons.chat_bubble_outline,
        title: 'Allow Direct Messages',
        subtitle: 'Let listeners send you direct messages',
        value: controller.allowDirectMessages,
        onChanged: notifier.toggleAllowDirectMessages,
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryWhite.withValues(alpha: 0.10),
          width: 1.09,
        ),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final row = entry.value;
          final isLast = entry.key == rows.length - 1;
          return PrivacyRow(
            icon: row.icon,
            title: row.title,
            subtitle: row.subtitle,
            value: row.value,
            onChanged: row.onChanged,
            showDivider: !isLast,
          );
        }).toList(),
      ),
    );
  }
}

class _PrivacyRowData {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrivacyRowData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
}
