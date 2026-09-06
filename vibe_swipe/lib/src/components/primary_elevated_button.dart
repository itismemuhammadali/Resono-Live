import 'package:flutter/cupertino.dart';
import '../core/utils/app_exports.dart';

class PrimaryElevatedButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final bool loader, enabled;
  final Color? backgroundColor, textColor, loaderColor, disableButtonTextColor;
  final double? height, loaderSize;
  final double width;
  final TextStyle? style;
  final num? radius;
  final ButtonStyle? buttonStyle;
  final IconData? trailingIcon;
  final Widget? leadingWidget;

  const PrimaryElevatedButton({
    super.key,
    required this.onTap,
    required this.text,
    this.loader = false,
    this.backgroundColor,
    this.disableButtonTextColor,
    this.textColor,
    this.height,
    this.width = double.infinity,
    this.enabled = true,
    this.style,
    this.radius,
    this.loaderColor,
    this.buttonStyle,
    this.loaderSize,
    this.trailingIcon,
    this.leadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return SizedBox(
      width: width,
      height: isPortrait ? height ?? 56.h : 50,
      child: ElevatedButton(
        onPressed: enabled ? (loader ? null : onTap) : null,
        style:
            buttonStyle ??
            ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: radius?.circular ?? 16.circular,
              ),
              backgroundColor: enabled
                  ? loader
                        ? loaderColor ?? AppColors.listenerActiveTab
                        : (backgroundColor ?? AppColors.listenerActiveTab)
                  : AppColors.inactiveGray,
              elevation: 0,
            ),
        child: loader
            ? SizedBox(
                width: loaderSize ?? 20.h,
                height: loaderSize ?? 20.h,
                child: (!kIsWeb && (Platform.isIOS || Platform.isMacOS))
                    ? CupertinoActivityIndicator(
                        color: textColor ?? AppColors.primaryblack,
                        radius: 10,
                      )
                    : CircularProgressIndicator(
                        strokeWidth: 3.0,
                        color: textColor ?? AppColors.primaryblack,
                        backgroundColor: AppColors.whitesmoke,
                      ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (leadingWidget != null) ...[leadingWidget!, 8.pw],
                  Flexible(
                    child: Text(
                      text,
                      style:
                          style ??
                          TextStyle(
                            fontFamily: 'Roboto',
                            color: enabled
                                ? (textColor ?? AppColors.primaryblack)
                                : (disableButtonTextColor ??
                                      AppColors.inactiveGray),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    8.pw,
                    Icon(
                      trailingIcon,
                      size: 14.sp,
                      color: enabled
                          ? (textColor ?? AppColors.primaryblack)
                          : AppColors.inactiveGray,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
