import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import '../../data/dtos/notification_dto.dart';

class NotificationDetailView extends StatelessWidget {
  const NotificationDetailView({super.key, required this.notification});

  final NotificationDto notification;

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.newSong:
      case NotificationType.newPerformance:
        return Icons.music_note_rounded;
      case NotificationType.promotion:
      case NotificationType.paymentConfirmed:
      case NotificationType.paymentFailed:
      case NotificationType.payoutProcessed:
        return Icons.card_giftcard_rounded;
      case NotificationType.feature:
      case NotificationType.sessionReminder:
      case NotificationType.trending:
        return Icons.notifications_rounded;
      case NotificationType.liveStream:
        return Icons.live_tv_rounded;
      case NotificationType.newFollower:
        return Icons.person_add_rounded;
      case NotificationType.postComment:
      case NotificationType.postLike:
        return Icons.forum_rounded;
      case NotificationType.performanceLike:
        return Icons.favorite_rounded;
      case NotificationType.tipReceived:
        return Icons.attach_money_rounded;
    }
  }

  String get _categoryLabel {
    switch (notification.type) {
      case NotificationType.newSong:
      case NotificationType.newPerformance:
        return 'New Release';
      case NotificationType.promotion:
        return 'Promotion';
      case NotificationType.feature:
      case NotificationType.trending:
        return 'New Feature';
      case NotificationType.liveStream:
        return 'Live Now';
      case NotificationType.sessionReminder:
        return 'Session Reminder';
      case NotificationType.newFollower:
        return 'New Follower';
      case NotificationType.postComment:
        return 'Comment';
      case NotificationType.postLike:
      case NotificationType.performanceLike:
        return 'Like';
      case NotificationType.tipReceived:
        return 'Tip Received';
      case NotificationType.paymentConfirmed:
        return 'Payment Confirmed';
      case NotificationType.paymentFailed:
        return 'Payment Failed';
      case NotificationType.payoutProcessed:
        return 'Payout Processed';
    }
  }

  Color get _accentColor {
    switch (notification.type) {
      case NotificationType.newSong:
      case NotificationType.newPerformance:
      case NotificationType.promotion:
        return AppColors.listenerYellow;
      case NotificationType.feature:
      case NotificationType.trending:
      case NotificationType.sessionReminder:
        return AppColors.huegrey;
      case NotificationType.liveStream:
      case NotificationType.newFollower:
      case NotificationType.postComment:
      case NotificationType.postLike:
      case NotificationType.performanceLike:
      case NotificationType.tipReceived:
      case NotificationType.paymentConfirmed:
        return const Color(0xFF4ECDC4);
      case NotificationType.paymentFailed:
      case NotificationType.payoutProcessed:
        return const Color(0xFFFF6B6B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/png/app_background_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              ListenerPageHeader(title: _categoryLabel),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      32.ph,
                      _IconHero(icon: _icon, color: _accentColor),
                      24.ph,
                      _CategoryChip(label: _categoryLabel, color: _accentColor),
                      16.ph,
                      Text(
                        notification.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryWhite,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      8.ph,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14.sp,
                            color: AppColors.huegrey,
                          ),
                          4.pw,
                          Text(
                            notification.time,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.huegrey,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                      28.ph,
                      _BodyCard(body: notification.fullBody),
                      if (notification.actionLabel != null) ...[
                        32.ph,
                        PrimaryElevatedButton(
                          onTap: () {},
                          text: notification.actionLabel!,
                          backgroundColor: _accentColor,
                          textColor: _accentColor == AppColors.listenerYellow
                              ? AppColors.primaryblack
                              : AppColors.primaryWhite,
                          radius: 14,
                        ),
                      ],
                      32.ph,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconHero extends StatelessWidget {
  const _IconHero({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.05),
          ),
        ),
        Container(
          width: 96.w,
          height: 96.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.10),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1.5.w,
            ),
          ),
          child: Icon(icon, color: color, size: 44.sp),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: 20.circular,
        border: Border.all(color: color.withValues(alpha: 0.30), width: 1.w),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: color,
          fontFamily: 'Roboto',
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _BodyCard extends StatelessWidget {
  const _BodyCard({required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: 16.circular,
        border: Border.all(
          color: AppColors.primaryWhite.withValues(alpha: 0.06),
          width: 1.w,
        ),
      ),
      child: Text(
        body,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.primaryWhite.withValues(alpha: 0.85),
          fontFamily: 'Roboto',
          height: 1.65,
        ),
      ),
    );
  }
}
