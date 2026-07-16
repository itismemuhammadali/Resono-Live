import 'package:flutter_screenutil/flutter_screenutil.dart';

mixin AppSize {
  double get screenWidth => ScreenUtil().screenWidth;
  double get screenHeight => ScreenUtil().screenHeight;

  bool get isMobile => screenWidth < 600.0;

  bool get isTablet => screenWidth >= 600.0 && screenWidth < 1000.0;

  bool get isDesktop => screenWidth >= 1000.0;

  double get maxWidth => double.infinity;

  //Text Sizing

  double get labelSmall => 11.sp;
  double get bodySmall => 12.sp;
  double get labelMedium => 12.sp;
  double get titleSmall => 13.sp;
  double get labelLarge => 16.sp;
  double get bodyMedium => 14.sp;
  double get titleMedium => 14.sp;
  double get bodyLarge => 16.sp;
  double get titleLarge => 19.sp;
  double get headlineSmall => 24.sp;
  double get headlineMedium => 28.sp;
  double get headlineLarge => 32.sp;
  double get displaySmall => 36.sp;
  double get displayMedium => 45.sp;
  double get displayLarge => 57.sp;

  double get appBarElevation => 20.sp;
  double get widgetElevation => 10.sp;
  double get containerWidth => 50.w;
  double get containerHeight => 55.w;
  double get cardWidth => 42.w;
  double get cardHeight => 42.w;
  double get imageWidth => 45.sp;
  double get imageHeight => 45.sp;
  double get imageScale => 0.8;
  double get tapPadding => 10.sp;
  double get paddingAll => 20.sp;
  double get paddingLeft => 15.sp;
  double get paddingRight => 15.sp;
  double get paddingTop => 15.sp;
  double get paddingBottom => 15.sp;
  double get dividerThickness => 10.sp;
  double get headSize => 18.sp;
  double get buttonTextSize => 18.sp;
  double get textSize => 15.sp;
  double get middleSize => 18.sp;

  double get buttonBorder => 12.sp;
  double get fieldBorder => 12.sp;
  double get borderRadius => 15.sp;
  double get logoHeight => 50.sp;
  double get logoWidth => 50.sp;
  double get buttonHeight => 48;
  double get buttonWidth => 36.sp;
  double get iconPadding => 20.sp;
  double get progressor => 32.h;
  double get screensPadding => 16;
  double get checkBoxScale => 1.0;
  double get appBarHeight => 60;
  double get appBarBackButtonSize => 38;
  double get appBarIconSize => 18;
  double get pinputHeight => 65;
  double get pinputWeight => 62;
  double get loginSize => 0;
}
