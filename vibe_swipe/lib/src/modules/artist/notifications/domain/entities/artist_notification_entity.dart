import 'package:flutter/material.dart';

class ArtistNotificationEntity {
  final String iconAsset;
  final Color iconColor;
  final String title;
  final String timeAgo;
  final bool isRead;

  const ArtistNotificationEntity({
    required this.iconAsset,
    required this.iconColor,
    required this.title,
    required this.timeAgo,
    this.isRead = false,
  });
}
