import 'dart:async';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/authentication_controller.dart';

class EmailVerificationDialog extends ConsumerStatefulWidget {
  final String email;
  final String targetRoute;
  final bool isSignUp;
  final VoidCallback? onChangeEmail;

  const EmailVerificationDialog({
    super.key,
    required this.email,
    required this.targetRoute,
    this.isSignUp = false,
    this.onChangeEmail,
  });

  static Future<void> show(
    BuildContext context, {
    required String email,
    required String targetRoute,
    bool isSignUp = false,
    VoidCallback? onChangeEmail,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => EmailVerificationDialog(
        email: email,
        targetRoute: targetRoute,
        isSignUp: isSignUp,
        onChangeEmail: onChangeEmail,
      ),
    );
  }

  @override
  ConsumerState<EmailVerificationDialog> createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState
    extends ConsumerState<EmailVerificationDialog> with WidgetsBindingObserver {
  Timer? _timer;
  bool _isVerified = false;
  bool _isResending = false;
  String? _resendMessage;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  bool _hasDismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startAutoPolling();
    _checkVerificationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkVerificationStatus();
    }
  }

  void _startAutoPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkVerificationStatus();
    });
  }

  void _handleChangeEmail({bool popRoute = true}) {
    if (_hasDismissed) return;
    _hasDismissed = true;
    _timer?.cancel();
    _cooldownTimer?.cancel();
    if (popRoute && mounted) {
      Navigator.of(context).pop();
    }
    widget.onChangeEmail?.call();
    if (widget.isSignUp) {
      ref.read(authControllerProvider).cancelPendingSignUp();
    } else {
      ref.read(authControllerProvider).cancelPendingLogin();
    }
  }

  Future<void> _checkVerificationStatus() async {
    if (_isVerified || _hasDismissed) return;
    final controller = ref.read(authControllerProvider);
    final verified = await controller.checkEmailVerified();
    if (verified && mounted && !_isVerified && !_hasDismissed) {
      setState(() {
        _isVerified = true;
      });
      _timer?.cancel();

      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted && !_hasDismissed) {
        _hasDismissed = true;
        Navigator.of(context).pop();
        AppRouterGo.pushReplacement(widget.targetRoute);
      }
    }
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown > 0 || _isResending) return;
    setState(() {
      _isResending = true;
      _resendMessage = null;
    });

    final controller = ref.read(authControllerProvider);
    final success = await controller.resendVerificationEmail();

    if (mounted) {
      setState(() {
        _isResending = false;
        if (success) {
          _resendMessage = "Verification email resent! Check your inbox.";
          _resendCooldown = 30;
          _startCooldown();
        } else {
          _resendMessage = "Failed to resend email. Please try again.";
        }
      });
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() {
          _resendCooldown = 0;
        });
      } else {
        setState(() {
          _resendCooldown--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isVerified,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && !_isVerified) {
          _handleChangeEmail(popRoute: false);
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: const Color(0xFF14141A),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: AppColors.listenerChipBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (!_isVerified)
                Positioned(
                  top: -8.h,
                  right: -8.w,
                  child: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.santagrey,
                      size: 22.sp,
                    ),
                    onPressed: () => _handleChangeEmail(popRoute: true),
                    tooltip: "Change email",
                  ),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isVerified) ...[
                    Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.greenAccent.withValues(alpha: 0.15),
                        border: Border.all(
                          color: Colors.greenAccent.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 42.sp,
                        color: Colors.greenAccent,
                      ),
                    ),
                    20.ph,
                    Text(
                      "Verification Completed! 🎉",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryWhite,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    8.ph,
                    Text(
                      "Your email has been successfully verified. Setting up your profile...",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.sp,
                        color: AppColors.santagrey,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    24.ph,
                    SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.listenerYellow.withValues(alpha: 0.15),
                        border: Border.all(
                          color: AppColors.listenerYellow.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.mark_email_unread_rounded,
                        size: 38.sp,
                        color: AppColors.listenerYellow,
                      ),
                    ),
                    20.ph,
                    Text(
                      "Verify Your Email",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryWhite,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    12.ph,
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14.sp,
                          color: AppColors.santagrey,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: "We sent a verification link to\n"),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              color: AppColors.primaryWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(
                            text: ".\nPlease check your Gmail or Mail app and tap the link to verify your account.",
                          ),
                        ],
                      ),
                    ),
                    20.ph,
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: AppColors.listenerChipBg,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.listenerChipBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14.w,
                            height: 14.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.listenerYellow,
                              ),
                            ),
                          ),
                          10.pw,
                          Text(
                            "Waiting for email verification...",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 13.sp,
                              color: AppColors.santagrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_resendMessage != null) ...[
                      12.ph,
                      Text(
                        _resendMessage!,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12.sp,
                          color: _resendMessage!.contains("resent")
                              ? AppColors.listenerYellow
                              : Colors.red[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    20.ph,
                    TextButton(
                      onPressed: (_resendCooldown > 0 || _isResending)
                          ? null
                          : _resendEmail,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.listenerYellow,
                        disabledForegroundColor: AppColors.santagrey,
                      ),
                      child: _isResending
                          ? SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.listenerYellow,
                                ),
                              ),
                            )
                          : Text(
                              _resendCooldown > 0
                                  ? "Resend Email ($_resendCooldown s)"
                                  : "Resend Verification Email",
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: _resendCooldown > 0
                                    ? AppColors.santagrey
                                    : AppColors.listenerYellow,
                              ),
                            ),
                    ),
                    if (!_isVerified) ...[
                      4.ph,
                      GestureDetector(
                        onTap: () => _handleChangeEmail(popRoute: true),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 13.sp,
                                color: AppColors.santagrey,
                              ),
                              children: const [
                                TextSpan(text: "Wrong email? "),
                                TextSpan(
                                  text: "Change email",
                                  style: TextStyle(
                                    color: AppColors.listenerYellow,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.listenerYellow,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
