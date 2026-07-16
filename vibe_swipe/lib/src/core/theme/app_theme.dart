import 'package:flutter/material.dart';
import '../services/routing_service/named_routes.dart';
import '../theme/app_colors.dart';
import '../theme/no_transitions_builder.dart';
import '../utils/app_size.dart';

mixin AppTheme on AppSize {
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    textTheme: TextTheme(
      labelSmall: TextStyle(
        fontSize: labelSmall, //
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      bodySmall: TextStyle(
        fontSize: bodySmall,
        color: AppColors.primaryText,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      ),
      displaySmall: TextStyle(
        fontSize: displaySmall,
        color: AppColors.primaryText,
        fontWeight: FontWeight.w500,
        fontFamily: 'Roboto',
      ),
      titleSmall: TextStyle(
        fontSize: titleSmall,
        color: AppColors.primaryText,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      ),
      titleMedium: TextStyle(
        fontSize: titleMedium,
        color: AppColors.primaryText,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      ),
      bodyMedium: TextStyle(
        fontSize: bodyMedium,
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      bodyLarge: TextStyle(
        fontSize: bodyLarge,
        color: AppColors.primaryText,
        fontWeight: FontWeight.w700,
        fontFamily: 'Roboto',
      ),
      labelMedium: TextStyle(
        fontSize: labelMedium,
        color: AppColors.primaryText,
        fontWeight: FontWeight.w500,
        fontFamily: 'Roboto',
      ),
      labelLarge: TextStyle(
        fontSize: labelLarge,
        color: AppColors.primaryText,
        fontWeight: FontWeight.w500,
        fontFamily: 'Roboto',
      ),
      displayMedium: TextStyle(
        fontSize: displayMedium,
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      displayLarge: TextStyle(
        fontSize: displayLarge,
        color: AppColors.primaryText,
        fontWeight: FontWeight.w700,
        fontFamily: 'Roboto',
      ),
      titleLarge: TextStyle(
        fontSize: titleLarge,
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      headlineSmall: TextStyle(
        fontSize: headlineSmall,
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      headlineMedium: TextStyle(
        fontSize: headlineMedium,
        color: AppColors.primaryText,
        fontWeight: FontWeight.w700,
        fontFamily: 'Roboto',
      ),
      headlineLarge: TextStyle(
        fontSize: headlineLarge,
        color: AppColors.primaryText,
        fontWeight: FontWeight.w800,
        fontFamily: 'Roboto',
      ),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: AppColors.drawerGreen),
    scaffoldBackgroundColor: AppColors.primaryWhite,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      linearMinHeight: 4,
      color: AppColors.backgroundPrimary,
      // linearTrackColor: AppColors.backgroundPrimary,
      circularTrackColor: AppColors.drawerGreen,
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
    dividerColor: AppColors.primaryText,
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.primaryWhite),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: NoTransitionsBuilder(),
        TargetPlatform.iOS: NoTransitionsBuilder(),
        TargetPlatform.windows: NoTransitionsBuilder(),
        TargetPlatform.macOS: NoTransitionsBuilder(),
        TargetPlatform.linux: NoTransitionsBuilder(),
        TargetPlatform.fuchsia: NoTransitionsBuilder(),
      },
    ),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    drawerTheme: const DrawerThemeData(
      // backgroundColor: AppColors.drawerGreen,
    ),
    appBarTheme: const AppBarTheme(
      //  backgroundColor: AppColors.primaryText,
      backgroundColor: AppColors.primaryText,
    ),
    scaffoldBackgroundColor: AppColors.primaryText,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundPrimary,
    ),
    textTheme: TextTheme(
      labelSmall: TextStyle(
        fontSize: labelSmall,
        color: AppColors.primaryWhite,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      bodySmall: TextStyle(
        fontSize: bodySmall,
        color: AppColors.primaryWhite,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      ),
      displaySmall: TextStyle(
        fontSize: displaySmall,
        color: AppColors.primaryWhite,
        fontWeight: FontWeight.w500,
        fontFamily: 'Roboto',
      ),
      titleSmall: TextStyle(
        fontSize: titleSmall,
        color: AppColors.primaryWhite,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      ),
      titleMedium: TextStyle(
        fontSize: titleMedium,
        color: AppColors.primaryWhite,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      ),
      bodyMedium: TextStyle(
        fontSize: bodyMedium,
        color: AppColors.primaryWhite,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      bodyLarge: TextStyle(
        fontSize: bodyLarge,
        color: AppColors.primaryWhite,
        fontWeight: FontWeight.w700,
        fontFamily: 'Roboto',
      ),
      labelMedium: TextStyle(
        fontSize: labelMedium,
        color: AppColors.primaryWhite,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      labelLarge: TextStyle(
        fontSize: labelLarge,
        color: AppColors.primaryWhite,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      displayMedium: TextStyle(
        fontSize: displayMedium,
        color: AppColors.primaryWhite,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      displayLarge: TextStyle(
        fontSize: displayLarge,
        color: AppColors.primaryWhite,
        fontWeight: FontWeight.w700,
        fontFamily: 'Roboto',
      ),
      titleLarge: TextStyle(
        fontSize: titleLarge,
        color: AppColors.primaryWhite,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      headlineSmall: TextStyle(
        fontSize: headlineSmall,
        color: AppColors.primaryWhite,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontSize: headlineMedium,
        color: AppColors.primaryWhite,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: TextStyle(
        fontSize: headlineLarge,
        color: AppColors.primaryWhite,
        fontWeight: FontWeight.w800,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryOrange,
      // linearTrackColor: AppColors.secondaryGold,
      // circularTrackColor: AppColors.secondaryGold,
    ),
    iconTheme: const IconThemeData(color: AppColors.iconColor),
    dividerColor: AppColors.dividerColor,
  );
}

ThemeData get theme => Theme.of(AppRouterGo.context);
