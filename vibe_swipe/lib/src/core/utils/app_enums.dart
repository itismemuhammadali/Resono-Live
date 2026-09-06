// App Enums
import 'package:flutter/material.dart';

enum PerformanceStatus { upcoming, past, pending, live }

enum PerformanceMenuAction { edit, startLive, delete }

enum UserRole { artist, listener }

enum NotificationType {
  newSong,
  promotion,
  feature,
  trending,
  liveStream,
  sessionReminder,
  newFollower,
  newPerformance,
  postComment,
  postLike,
  performanceLike,
  tipReceived,
  paymentConfirmed,
  paymentFailed,
  payoutProcessed,
}

enum ArtistPostLinkType { none, track, performance }

enum AnalyticsPeriod { sevenDays, thirtyDays, allTime }
// import 'package:pakistan_cables_mobile/src/modules/stock_management/stock_anagement_barrel.dart';

enum ProductColor {
  red(Colors.red),
  blue(Colors.blue),
  green(Colors.green);

  final Color color;
  const ProductColor(this.color);

  /// Utility to get ProductColor from a string
  static ProductColor? fromString(String value) {
    try {
      return ProductColor.values
          .firstWhere((e) => e.name == value.toLowerCase());
    } catch (_) {
      return null; // Handle invalid color names
    }
  }
}

// class ProductItemHelper {
//   final GetProductByIdModel productModel;

//   ProductItemHelper(this.productModel);

//   /// Converts the color string of a product item at the given index to a `ProductColor` enum.
//   ProductColor? colorEnum(int index) {
//     final colorString = productModel.data?.productItems?[index].color;
//     return ProductColor.fromString(colorString ?? '');
//   }

//   /// Returns the hex color value for the color of a product item at the given index.
//   Color colorHex(int index) {
//     return colorEnum(index)?.color ?? Colors.grey;
//   }
// }

class ProductItemHelper {
  ProductColor? colorEnum(String colourName) {
    return ProductColor.fromString(colourName);
  }

  Color colorHex(String colourName) {
    return colorEnum(colourName)?.color ?? Colors.grey;
  }
}
