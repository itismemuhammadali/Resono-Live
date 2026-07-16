import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppInsets {
  static EdgeInsets only({
    double top = 0,
    double bottom = 0,
    double right = 0,
    double left = 0,
  }) =>
      EdgeInsets.only(
        top: top.h,
        bottom: bottom.h,
        left: left.w,
        right: right.w,
      );
  static EdgeInsets symmetric({
    double horizontal = 0,
    double vertical = 0,
  }) =>
      EdgeInsets.symmetric(
        horizontal: horizontal.w,
        vertical: vertical.h,
      );
  static EdgeInsets all([
    double all = 0,
  ]) =>
      EdgeInsets.all(all.w);
}
