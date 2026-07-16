import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.title,
    required this.body,
    required this.fullBody,
    required this.time,
    required this.type,
    this.isRead = false,
    this.actionLabel,
  });

  final String id;
  final String title;
  final String body;
  final String fullBody;
  final String time;
  final NotificationType type;
  final bool isRead;
  final String? actionLabel;
}
