// ignore_for_file: strict_top_level_inference

import 'package:flutter/cupertino.dart';
import 'package:vibe_swipe/src/components/glass_toast.dart';
import 'app_exports.dart';

class Prompts {
  static Future<void> noInternetDialog() async {
    ScaffoldMessenger.of(AppRouterGo.context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        // backgroundColor: pinchToastColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            "No Internet Connection",
            style: TextStyle(
              fontFamily: 'Roboto',
              color: AppColors.primaryWhite,
              fontSize: 12.sp,
            ),
          ),
        ),
        action: SnackBarAction(
          label: "Close",
          textColor: AppColors.primaryWhite,
          onPressed: () {
            ScaffoldMessenger.of(AppRouterGo.context).hideCurrentSnackBar();
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static void showSnackBar(String message, {Duration? duration, Color? color}) {
    ScaffoldMessenger.of(AppRouterGo.context).clearSnackBars();
    ScaffoldMessenger.of(AppRouterGo.context).showSnackBar(
      SnackBar(
        showCloseIcon: true,
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            message,
            style: TextStyle(
              fontFamily: 'Roboto',
              color: AppColors.primaryWhite,
              fontSize: 14.sp,
            ),
          ),
        ),
        duration: duration ?? const Duration(seconds: 5),
      ),
    );
  }

  static void showMaterialBanner(
    String message, {
    Duration? duration,
    Color? color,
    bool isSuccess = true,
  }) {
    final context = AppRouterGo.context;

    // Clear any existing MaterialBanner
    ScaffoldMessenger.of(context).clearMaterialBanners();

    // Show the MaterialBanner
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(
          message,
          style: context.bodyMediumStyle?.copyWith(color: AppColors.primaryWhite),
        ),
        backgroundColor:
            color ?? (isSuccess ? AppColors.primaryGreen : AppColors.eventRed),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: Text(
              'Dismiss',
              style: context.bodyMediumStyle?.copyWith(color: AppColors.primaryWhite),
            ),
          ),
        ],
        onVisible: () {
          Future.delayed(const Duration(seconds: 5), () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            }
          });
        },
        elevation: 6,
        padding: const EdgeInsets.only(top: 0, left: 8),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  static void popMessenger(String message, {Duration? duration}) {
    ScaffoldMessenger.of(AppRouterGo.context).clearSnackBars();
    ScaffoldMessenger.of(AppRouterGo.context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        showCloseIcon: true,
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Container(
                width: 30.w,
                height: 30.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryText,
                  border: Border.all(color: AppColors.primaryText),
                ),
                child: Icon(Icons.check, color: AppColors.primaryWhite, size: 16.sp),
              ),
              10.pw,
              Text(
                message.contains('Exception:')
                    ? message.replaceAll('Exception: ', '')
                    : message,
                style: AppTextTheme.titleMediumBlack14,
              ),
            ],
          ),
        ),
        duration: duration ?? const Duration(seconds: 5),
      ),
    );
  }

  static void showPermissionSnackBar(String message, VoidCallback onTap) {
    ScaffoldMessenger.of(AppRouterGo.context).clearSnackBars();
    ScaffoldMessenger.of(AppRouterGo.context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        // backgroundColor: pinchToastColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            message,
            style: TextStyle(
              fontFamily: 'Roboto',
              color: AppColors.primaryWhite,
              fontSize: 12.sp,
            ),
          ),
        ),
        action: SnackBarAction(
          label: "Go",
          textColor: AppColors.primaryWhite,
          onPressed: () {
            onTap();
            ScaffoldMessenger.of(AppRouterGo.context).hideCurrentSnackBar();
          },
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  static Future<dynamic> showLogoutAlert(
    context, {
    required String title,
    VoidCallback? onLogout,
    content,
  }) {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            title,
            style: AppTextTheme.titleMediumBlue16?.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        content: Text(
          content,
          style: AppTextTheme.titleMediumBlack14?.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(
              "Cancel",
              style: AppTextTheme.titleMediumBlack16?.copyWith(
                fontSize: 17.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            onPressed: onLogout,
            child: Text(
              "Logout",
              style: AppTextTheme.titleMediumBlack16?.copyWith(
                color: AppColors.eventRed,
                fontSize: 17.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<dynamic> showDeleteAccountAlert(
    context, {
    required String title,
    required TextEditingController controller,
    VoidCallback? onSubmit,
    onTapSuffix,
    required bool isObscure,
    content,
  }) {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        title: Padding(
          padding: AppInsets.only(bottom: 12.0),
          child: Text(
            title,
            style: AppTextTheme.titleMediumBlue16?.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        content: Column(
          children: [
            Text(
              content,
              style: AppTextTheme.titleMediumBlack14?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            10.ph,
            CupertinoTextField(
              controller: controller,
              obscureText: isObscure,
              placeholder: AppStrings.password,
              suffix: CupertinoButton(
                onPressed: onTapSuffix,
                child: Icon(
                  !isObscure ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.primaryGrey,
                  size: 16.sp,
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(
              "Cancel",
              style: AppTextTheme.titleMediumBlack16?.copyWith(
                color: theme.primaryColor,
                fontSize: 17.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            onPressed: onSubmit,
            child: Text(
              "Confirm",
              style: AppTextTheme.titleMediumBlack16?.copyWith(
                color: AppColors.primaryText,
                fontSize: 17.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void showBottomSheet(
    BuildContext context,
    Widget Function(BuildContext) builder,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: AppColors.primaryWhite,
      context: context,
      builder: builder,
    );
  }

  static void showToast(
    String message, {
    bool isSuccess = true,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Use navigatorKey to get the overlay of the root navigator
    final overlayState =
        AppRouterGo.appRouter.routerDelegate.navigatorKey.currentState?.overlay;

    if (overlayState == null) return;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastOverlay(
        message: message,
        isSuccess: isSuccess,
        duration: duration,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlayState.insert(overlayEntry);
  }
}

class _ToastOverlay extends StatefulWidget {
  final String message;
  final bool isSuccess;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastOverlay({
    required this.message,
    required this.isSuccess,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeOutCubic,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.elasticOut,
            reverseCurve: Curves.easeOutCubic,
          ),
        );

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 0,
      right: 0,
      child: Material(
        color: AppColors.transparent,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: GlassToast(
                message: widget.message,
                isSuccess: widget.isSuccess,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
