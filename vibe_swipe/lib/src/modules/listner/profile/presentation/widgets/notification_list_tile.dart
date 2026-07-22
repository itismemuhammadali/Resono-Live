import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../data/dtos/notification_dto.dart';

class NotificationListTile extends StatelessWidget {
  const NotificationListTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final NotificationDto notification;
  final VoidCallback onTap;

  String get _assetPath {
    switch (notification.type) {
      case NotificationType.newSong:
      case NotificationType.newPerformance:
        return AppAssetsPng.notifNewSongIcn;
      case NotificationType.promotion:
      case NotificationType.paymentConfirmed:
      case NotificationType.paymentFailed:
      case NotificationType.payoutProcessed:
        return AppAssetsPng.notifPromotionIcn;
      case NotificationType.feature:
      case NotificationType.sessionReminder:
      case NotificationType.trending:
        return AppAssetsPng.notifFeatureIcn;
      case NotificationType.liveStream:
        return AppAssetsPng.profileNotificationTabIcn;
      case NotificationType.newFollower:
        return 'assets/icons/png/artist_notification_new_followers_icn.png';
      case NotificationType.postComment:
      case NotificationType.postLike:
      case NotificationType.performanceLike:
        return 'assets/icons/png/artist_notification_track_comments_icn.png';
      case NotificationType.tipReceived:
        return 'assets/icons/png/artist_notification_track_performance_icn.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.listenerYellow.withValues(alpha: 0.10)
              : AppColors.listenerChipBg,
          borderRadius: 16.circular,
          border: isUnread
              ? Border.all(
                  color: AppColors.listenerYellow.withValues(alpha: 0.30),
                  width: 1.09.w,
                )
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isUnread
                    ? AppColors.listenerYellow
                    : AppColors.listenerBackButtonBorder,
                borderRadius: 12.circular,
              ),
              child: Image.asset(
                _assetPath,
                color: isUnread
                    ? AppColors.primaryblack
                    : AppColors.listenerYellow,
              ),
            ),
            16.pw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryWhite,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  4.ph,
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.huegrey,
                      fontFamily: 'Roboto',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  6.ph,
                  Text(
                    notification.time,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.huegrey.withValues(alpha: 0.6),
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread) ...[
              12.pw,
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: AppColors.listenerYellow,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
