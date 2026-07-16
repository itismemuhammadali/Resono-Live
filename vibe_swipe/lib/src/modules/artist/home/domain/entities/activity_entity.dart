import 'package:flutter/material.dart';

class ActivityEntity {
  final String? asset;
  final IconData? icon;
  final Color iconBgColor;
  final String description;
  final String timeAgo;

  const ActivityEntity({
    required this.iconBgColor,
    required this.description,
    required this.timeAgo,
    this.asset,
    this.icon,
  });
}
