import 'package:flutter/material.dart';

class AppColors {
  // static String colorToHexString(Color color) {
  //   return '#${color.red.toRadixString(16).padLeft(2, '0').toUpperCase()}'
  //       '${color.green.toRadixString(16).padLeft(2, '0').toUpperCase()}'
  //       '${color.blue.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  // }

  static Color hexStringToColor(String hexString) {
    hexString = hexString.replaceFirst('#', '');
    return Color(int.parse('FF$hexString', radix: 16));
  }

  // Background Colors
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent; // Light beige background
  static const Color primaryGreen = Color(
    0xFF1F8E4B,
  ); // Dark green sidebar background
  static const Color drawerGreen = Color(
    0xFF008444,
  ); // Dark green sidebar background
  static const Color secondaryGreen = Color(
    0xFF008444,
  ); // Dark green sidebar background
  // White color
  static const Color primaryGrey = Colors.grey; // White color

  // Text Colors
  //  static const Color primaryText = Color(0xFF121212); // Black/Dark text
  static const Color primaryText = Color(0xFF101828);
  static const Color secondaryText = Color(
    0xFF767676,
  ); // Grey text (for dates and smaller text)

  // Highlighted or Alert Colors
  static const Color notificationBadge = Color(
    0xFFE65C00,
  ); // Orange badge color (Notification bubble)

  // Button or Active Element Colors
  static const Color buttonColor = Color(
    0xFFFEC041,
  ); // Orange button color ("Start Now")

  // Event Tag Colors
  static const Color eventBlue = Color(
    0xFF438AFD,
  ); // Blue (used for "Pakistan Cables - CCV Cables" and "Last chance to buy")
  static const Color eventOrange = Color(
    0xFFFF8250,
  ); // Orange (used for "SALE Accessories")
  static const Color eventGreen = Color(
    0xFF328047,
  ); // Green (used for "Sale under 150" and others)
  static const Color eventRed = Color(
    0xFFD74C47,
  ); // Red (used for "Last chance to buy")
  static const Color eventYellow = Color(
    0xFFFFC041,
  ); // Yellow (used for highlighted events)

  // Divider or Border Colors
  static const Color borderColor = Color(0xFFDEE5EB); // Light grey for borders
  static const Color borderGreen = Color(0xFF4FAC34); // Light green for borders

  // Misc Colors
  static const Color iconColor = Color(
    0xFF009639,
  ); // Green accent (used in logo)

  //Colors For ZIM Sports
  static const primaryTextColor = Color(0xff101828);
  static const splashBackground = Color(0xFFF2ECE0);
  static const Color inactiveGray = Color(0xFF999999);
  static const Color purple = Color(0xFFA36CF7);

  static const Color primaryWhite = Colors.white;
  static const Color primaryblack = Colors.black;
  static const Color hueBlack = Color(0xFF141414);
  static const Color huegrey = Color(0xFF808797);
  static const Color lightPink = Color(0xFFFFB4B0);
  static const Color lightPeach = Color(0xFFFFD99F);
  static const Color lightBlue = Color(0xFF9FCDDF);
  static const Color lightGreen = Color(0xFF8FC7A5);
  static const Color redish = Color(0x0ff5322b);
  static const Color mudBrown = Color(0xFFEBCFA6);
  static const Color black = Color(0xFF1F2022);
  static const Color blackpearl = Color(0xFF101828);
  static const Color red500 = Color(0xFFF95555);
  static const Color vibrantPinkishRed = Color(0xffF54975);
  static const Color darkGray = Color(0xff2B2B2B);
  static const Color gray600 = Color(0xFF475467);
  static const Color gray500 = Color(0xFF667085);
  static const Color gray400 = Color(0xFF393B41);
  static const Color gray50 = Color(0xFFEBECEE);
  static const Color charcoalgrey = Color(0xFF393B41);
  static const Color textBody = Color(0xFF344054);
  static const Color gray300 = Color(0xFFD0D5DD);
  static const Color gray200 = Color(0xFFEAECF0);
  static const Color gray100 = Color(0xFFF9FAFB);
  static const Color lightGrey = Color(0xffE7E7E7);
  static const Color snowWhite = Color(0xffF9F9F9);
  static const Color green500 = Color(0xFF19B36E);
  static const Color green50 = Color(0xFFE8F7F1);
  static const Color iconGreen = Color(0xFF10B981);
  static const Color iconPurple = Color(0xFF8A66FB);
  static const Color purpleShade = Color(0xFFEBE9FE);
  static const Color purple25 = Color(0xFFFAFAFF);
  static const Color dividerColor = Color(0xFFEBEFFA);
  static const Color primarytext = Color(0xFF101828);
  static const Color chartgridColor = Color(0xFFE2E6F0);
  static const Color shadeGrey = Color(0xFFF7F7F7);
  static const Color primaryOrange = Color(0xFFF69246);
  static const Color iconYellow = Color(0xFFF59E0B);
  static const Color coralOrange = Color(0xffFD824C);
  static const Color fieryRed = Color(0xffF95555);
  static const Color goldenrod = Color(0xffFFC02E);
  static const Color mintGreen = Color(0xff47C28B);
  static const Color emeraldGreen = Color(0xFF00C950);
  static const Color blueLotus = Color(0xFF7A5AF8);
  static const Color ceramic = Color(0xFFFEFEFE);
  static const Color whitesmoke2 = Color(0xFFF4F5FF);
  static const Color catskillwhite = Color(0xffF1F3F8);
  static const Color mediumslateblue = Color(0xff6E62FF);
  static const Color purpleblue = Color(0xFF795FFC);
  static const Color purple500 = Color(0xFF7A5AF8);
  static const Color softpeach = Color(0xFFEDEAFF);
  static const Color whitesmoke = Color(0xFFF6F6F6);
  static const Color surfacePrimary = Color(0xFFFEFEFE);
  static const Color heavymetal = Color(0xFF2B2B2B);
  static const Color purplishBlue = Color(0xFF6938EF);
  static const Color davyGrey = Color(0x0fa75467);
  static const Color fog = Color(0xFFD9D6FE);
  static const Color titanWhite = Color(0xFFEBE9FE);
  static const Color aztecPurple = Color(0xFF7155FF);
  static const Color purple200 = Color(0xFFECE4FF);
  static const Color purple400 = Color(0xFF9B8AFB);
  static const Color dark = Color(0XFF161B23);
  static const Color santagrey = Color(0xFF98A2B3);
  static const Color purpleMimosa = Color(0xFF9B8AFB);
  static const Color vampireGrey = Color(0xFF475467);
  static const Color purple50 = Color(0xFFF4F3FF);
  static const Color purple100 = Color(0xFFEBE9FE);
  static const Color milkwhite = Color(0xFFFFFFFF);
  static const Color aquahaze = Color(0xFFF4F6F9);
  static const Color heavyMetal1 = Color(0xFF2D2D2D);
  static const Color night = Color(0xFF000000);
  static const Color casper = Color(0xFFB6C2D7);
  static const Color carnation = Color(0xFFF14E4E);
  static const Color purple300 = Color(0xFFBDB4FE);
  static const Color sprintColor = Color(0xFFA3ADC8);
  static const Color trout = Color(0xFF4F5464);
  static const Color zeus = Color(0xFF282828);
  static const Color antiqueWhite = Color(0xFFF9EBD4);
  static const Color schoolBusYellow = Color(0xffE5A325);
  static const Color greyGoose = Color(0xffD0D0D0);
  static const Color merino = Color(0xFFF5EDED);
  // static const Color greyGoose = Color(0xFFCCCCCC);
  static const Color tyrianPurple = Color(0xFFA36CF7);
  static const Color lavenderIndigo = Color(0xff995AF6);
  static const Color comet = Color(0xff495274);
  static const Color flatBlue = Color(0xff475BAE);
  static const Color wheatfield = Color(0xffF8E9D3);
  static const Color maleDialogBg = Color(0xFFF8F3EC);
  static const Color femaleDialogBg = Color(0xFFFAEBE1);
  static const Color rhino = Color(0xff32407B);
  static const Color listenerActiveTab = Color(0xFFFFD426);
  static const Color listenerDashboardBg = Color(0xFF0D121B);
  static const Color artistHomeAppBarBg = Color(0xFF020C14);
  static const Color listenerNavBorder = Color(0xFF1E2532);
  static const Color listenerGradientTop = Color(0xFF1A2639);
  static const Color listenerYellow = Color(0xFFFFD13B);
  static const Color listenerChipBg = Color(0xFF121821);
  static const Color listenerPopupMenuBg = Color(0xFF1C2535);
  static const Color listenerPastBadgeBg = Color(0xFF1E2530);
  static const Color listenerPendingBlue = Color(0xFF2B7FFF);
  static const Color deleteRed = Color(0xFFFF3B30);
  static const Color listenerChipBorder = Color(0xFF2C3140);
  static const Color listenerAvatarBg = Color(0xFF1A2233);
  static const Color artistStatItemBg = Color(0xFF1F2937);
  static const Color listenerDislikeRed = Color(0xFFE8445A);
  static const Color listenerLiveRed = Color(0xFFE7000B);
  static const Color artistLiveBadgeRed = Color(0xFFFB2C36);
  static const Color artistEndSessionRed = Color(0xFFEF4444);
  static const Color listenerBackButtonBorder = Color(0xFF1F2937);
  static const Color listenerCursorDark = Color(0xFF202020);
  static const Color black50 = Color(0x80000000);
  static const Color shimmerBase = Color(0xFFEBEBF4);
  static const Color shimmerContainer = Color(0xFFF4F4F4);
  static const Color shimmerHighlight = Color(0xB3FFFFFF);
  static const Color subtitleGray = Color(0xFF9E9E9E);
  static const Color inactiveDot = Color(0xFF3A3A3A);
  static const Color coolGray = Color(0xFF9CA3AF);
  static const Color hintGray = Color(0xFF6B7280);

  // Super Chat Colors
  static const Color superChatGold = Color(0xFFFFD700);
  static const Color superChatGoldDark = Color(0xFFE6B800);
  static const Color superChatNeon = Color(0xFF39FF14);

  // Super Chat Tier Colors
  static const Color superChatTier1Start = Color(0xFFCD7F32); // Bronze
  static const Color superChatTier1End = Color(0xFFA0522D);
  static const Color superChatTier2Start = Color(0xFFE0E0E0); // Silver
  static const Color superChatTier2End = Color(0xFF9E9E9E);
  static const Color superChatTier3Start = Color(0xFFFFD700); // Gold
  static const Color superChatTier3End = Color(0xFFFFA000);
  static const Color superChatTier3Accent = Color(0xFFFF9800);
  static const Color superChatTier4Start = Color(0xFFE5E4E2); // Platinum
  static const Color superChatTier4End = Color(0xFF9C27B0);

  // Badge-specific named colors
  static const Color superChatBronzeStart = Color(0xFFCD7F32);
  static const Color superChatBronzeEnd = Color(0xFFA0522D);
  static const Color superChatSilverStart = Color(0xFFE0E0E0);
  static const Color superChatSilverEnd = Color(0xFF9E9E9E);
  static const Color superChatGoldStart = Color(0xFFFFD700);
  static const Color superChatGoldEnd = Color(0xFFFFA000);
  static const Color superChatPlatinumStart = Color(0xFFE5E4E2);
  static const Color superChatPlatinumEnd = Color(0xFF9C27B0);
}
