import 'package:flutter/material.dart';

class ArtistStatEntity {
  final IconData icon;
  final Color iconColor;
  final IconData? secondIcon;
  final Color? secondIconColor;
  final String? iconAsset;
  final String? secondIconAsset;
  final String value;
  final String label;

  const ArtistStatEntity({
    required this.icon,
    required this.iconColor,
    this.secondIcon,
    this.secondIconColor,
    this.iconAsset,
    this.secondIconAsset,
    required this.value,
    required this.label,
  });
}
