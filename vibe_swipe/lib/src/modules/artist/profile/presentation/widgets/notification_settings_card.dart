import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/artist_profile_controller.dart';
import 'notification_row.dart';

class NotificationSettingsCard extends ConsumerWidget {
  const NotificationSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(artistProfileControllerProvider);
    final notifier = ref.read(artistProfileControllerProvider.notifier);

    final rows = [
      _NotificationRowData(
        asset: 'assets/icons/png/artist_notification_track_performance_icn.png',
        title: 'Track Performance',
        subtitle: 'Get updates on plays, saves, and engagement',
        value: controller.trackPerformance,
        onChanged: notifier.toggleTrackPerformance,
      ),
      _NotificationRowData(
        asset: 'assets/icons/png/artist_notification_compaign_icn.png',
        title: 'Campaign Updates',
        subtitle: 'New campaigns and participation status',
        value: controller.campaignUpdates,
        onChanged: notifier.toggleCampaignUpdates,
      ),
      _NotificationRowData(
        asset: 'assets/icons/png/artist_notification_track_comments_icn.png',
        title: 'Track Comments',
        subtitle: 'When listeners comment on your tracks',
        value: controller.trackComments,
        onChanged: notifier.toggleTrackComments,
      ),
      _NotificationRowData(
        asset: 'assets/icons/png/artist_notification_new_followers_icn.png',
        title: 'New Followers',
        subtitle: 'When someone follows your profile',
        value: controller.newFollowers,
        onChanged: notifier.toggleNewFollowers,
      ),
      _NotificationRowData(
        asset: 'assets/icons/png/artist_notification_platform_marketing_icn.png',
        title: 'Platform Messages',
        subtitle: 'Direct messages from listeners',
        value: controller.platformMessages,
        onChanged: notifier.togglePlatformMessages,
      ),
      _NotificationRowData(
        asset: 'assets/icons/png/artist_notification_platform_marketing_icn.png',
        title: 'Marketing Updates',
        subtitle: 'Tips, news, and product updates',
        value: controller.marketingUpdates,
        onChanged: notifier.toggleMarketingUpdates,
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
          return NotificationRow(
            asset: row.asset,
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

class _NotificationRowData {
  final String asset;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationRowData({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
}
