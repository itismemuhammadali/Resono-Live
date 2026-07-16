
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension AppExtensions on String {
  String get twoDigits => toString().padLeft(2, '0');

  String get commaSeparatedString {
    return toString().replaceAll('[', '').replaceAll(']', '');
  }

  String get formatDuration {
    try {
      final parts = split(':');
      if (parts.length == 2) {
        final minutes = int.tryParse(parts[0]) ?? 0;
        final seconds = int.tryParse(parts[1]) ?? 0;
        if (minutes < 1) {
          return '$minutes Hrs';
        }
        return '$minutes Hrs $seconds Sec';
      } else if (parts.length == 3) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        if (hours < 1) {
          return '$minutes Mins';
        }
        return '$hours Hrs $minutes Min';
      } else {
        return this;
      }
    } catch (e) {
      return this;
    }
  }

  String get filterException {
    if (contains("Exception: ")) {
      return replaceAll("Exception: ", '');
    }
    return this;
  }
}

extension Spacing on num {
  SizedBox get ph => SizedBox(height: toDouble().h);

  SizedBox get pw => SizedBox(width: toDouble().w);

  BorderRadius get circular => BorderRadius.circular(toDouble().r);
}

extension TextThemeExtensions on BuildContext {
  TextStyle? get labelSmallStyle => Theme.of(this).textTheme.labelSmall;
  TextStyle? get bodySmallStyle => Theme.of(this).textTheme.bodySmall;
  TextStyle? get displaySmallStyle => Theme.of(this).textTheme.displaySmall;
  TextStyle? get titleSmallStyle => Theme.of(this).textTheme.titleSmall;
  TextStyle? get titleMediumStyle => Theme.of(this).textTheme.titleMedium;
  TextStyle? get bodyMediumStyle => Theme.of(this).textTheme.bodyMedium;
  TextStyle? get bodyLargeStyle => Theme.of(this).textTheme.bodyLarge;
  TextStyle? get labelMediumStyle => Theme.of(this).textTheme.labelMedium;
  TextStyle? get labelLargeStyle => Theme.of(this).textTheme.labelLarge;
  TextStyle? get displayMediumStyle => Theme.of(this).textTheme.displayMedium;
  TextStyle? get displayLargeStyle => Theme.of(this).textTheme.displayLarge;
  TextStyle? get titleLargeStyle => Theme.of(this).textTheme.titleLarge;
  TextStyle? get headlineSmallStyle => Theme.of(this).textTheme.headlineSmall;
  TextStyle? get headlineMediumStyle => Theme.of(this).textTheme.headlineMedium;
  TextStyle? get headlineLargeStyle => Theme.of(this).textTheme.headlineLarge;
}

extension CapitalizeExtension on String {
  String get capitalizeEachWord {
    return split(' ') // Split the string into words
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : word) // Capitalize the first letter of each word and make the rest lowercase
        .join(' '); // Join the words back into a single string
  }

  String get formatTime {
    return '${split(':')[0]}:${split(':')[1]}';
  }

  bool get isValidUrl {
    // Regular expression for basic URL validation
    const urlPattern =
        r"^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$";
    final regExp = RegExp(urlPattern);

    // Check if the string matches the URL pattern and can be parsed as a URI
    return regExp.hasMatch(this) && Uri.tryParse(this)?.hasAbsolutePath == true;
  }
}
