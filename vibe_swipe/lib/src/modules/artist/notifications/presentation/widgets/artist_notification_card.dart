import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/artist_notification_entity.dart';

class ArtistNotificationCard extends StatelessWidget {
  const ArtistNotificationCard({super.key, required this.notification});

  final ArtistNotificationEntity notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: 16.circular,
        border: Border.all(
          color: AppColors.primaryWhite.withValues(alpha: 0.10),
          width: 1.09,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: notification.iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(child: Image.asset(notification.iconAsset)),
          ),
          16.pw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryWhite,
                  ),
                ),
                6.ph,
                Text(
                  notification.timeAgo,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.huegrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
