// ignore_for_file: strict_top_level_inference

import 'package:flutter/material.dart';

class PrecachingService {
  static Future<void> precacheAssetImage(
    dynamic assetImage,
    dynamic context,
  ) async {
    await precacheImage(AssetImage(assetImage), context);
  }

  static Future<void> precacheNetworkImage(
    dynamic networkImage,
    dynamic context,
  ) async {
    await precacheImage(NetworkImage(networkImage), context);
  }
}
