import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AppTextTheme {
  static TextStyle? get headlineLargeBlue {
    return theme.textTheme.headlineLarge?.copyWith(
      color: AppColors.primaryText,
      fontSize: 32.sp,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle? get bodyMediumBlack13 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.primaryText,
    );
  }

  static TextStyle? get bodyMediumBlack14 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.primaryText,
    );
  }

  static TextStyle? get bodyMediumWhite13 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 13.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.primaryWhite,
    );
  }

  static TextStyle? get titleSmall14 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.primaryText,
    );
  }

  static TextStyle? get titleSmall16 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.primaryText,
    );
  }

  static TextStyle? get titleSmall18 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 18.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.primaryText,
    );
  }

  static TextStyle? get bodyMediumGray13 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 13.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.primaryText,
    );
  }

  static TextStyle? get bodyNormalWhite14 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.primaryGreen,
    );
  }

  static TextStyle? get bodyNormalDark14 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.primaryText,
    );
  }

  static TextStyle? get titleMediumBlue14 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle? get titleMediumWhite14 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.primaryWhite,
    );
  }

  static TextStyle? get titleMediumBlack14 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.primaryText,
    );
  }

  static TextStyle? get titleMediumBlue16 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle? get titleMediumWhite16 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryWhite,
    );
  }

  static TextStyle? get titleMediumBlack16 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryText,
    );
  }

  static TextStyle? get bodyNormalDark16 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.primaryText,
    );
  }

  static TextStyle? get titleMediumBlue18 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle? get titleMediumWhite18 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryWhite,
    );
  }

  static TextStyle? get titleMediumBlack18 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryText,
    );
  }

  static TextStyle? get bodyNormalDark18 {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 18.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.primaryText,
    );
  }

  static TextStyle? get bodyLabelBlack {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.secondaryText,
    );
  }

  static TextStyle? get bodyLabelGrey {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.primaryText,
    );
  }

  static TextStyle? get chipLabelGreen {
    return theme.textTheme.bodyMedium?.copyWith(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.primaryGreen,
    );
  }

  // static TextStyle? get textPrimary {
  //   return theme.textTheme.bodyMedium?.copyWith(
  //     fontSize: 14.sp,
  //     fontWeight: FontWeight.w600,
  //     color: AppColors.primaryText,
  //   );
  // }
}
