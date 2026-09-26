import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_swipe/src/core/theme/app_colors.dart';
import 'package:vibe_swipe/src/core/utils/app_extensions.dart';

class PaymentSuccessView extends StatefulWidget {
  const PaymentSuccessView({super.key, required this.sessionId});

  final String sessionId;

  @override
  State<PaymentSuccessView> createState() => _PaymentSuccessViewState();
}

class _PaymentSuccessViewState extends State<PaymentSuccessView> {
  bool _isLoading = true;
  bool _isSuccess = false;
  String? _errorMessage;
  double? _netAmount;

  @override
  void initState() {
    super.initState();
    _confirmPayment();
  }

  Future<void> _confirmPayment() async {
    // The webhook handles the backend sync. We just show a success state here.
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: _isLoading
                ? _buildLoading()
                : _isSuccess
                    ? _buildSuccess()
                    : _buildError(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 48.w,
          height: 48.w,
          child: CircularProgressIndicator(
            color: AppColors.listenerYellow,
            strokeWidth: 3,
          ),
        ),
        24.ph,
        Text(
          'Confirming payment...',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16.sp,
            color: AppColors.santagrey,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.green500.withValues(alpha: 0.15),
            border: Border.all(
              color: AppColors.green500.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.check_rounded,
            color: AppColors.green500,
            size: 36.sp,
          ),
        ),
        24.ph,
        Text(
          'Payment Successful!',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryWhite,
          ),
        ),
        8.ph,
        Text(
          _netAmount != null
              ? 'Your tip of \$${(_netAmount! / 100).toStringAsFixed(2)} has been sent'
              : 'Your payment has been processed',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14.sp,
            color: AppColors.santagrey,
          ),
          textAlign: TextAlign.center,
        ),
        32.ph,
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: () => context.go('/listener-dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.listenerYellow,
              foregroundColor: AppColors.primaryblack,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: Text(
              'Back to Dashboard',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.red500.withValues(alpha: 0.15),
            border: Border.all(
              color: AppColors.red500.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.close_rounded,
            color: AppColors.red500,
            size: 36.sp,
          ),
        ),
        24.ph,
        Text(
          'Payment Failed',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryWhite,
          ),
        ),
        8.ph,
        Text(
          _errorMessage ?? 'Something went wrong. Please try again.',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14.sp,
            color: AppColors.santagrey,
          ),
          textAlign: TextAlign.center,
        ),
        32.ph,
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: () => context.go('/listener-dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.listenerYellow,
              foregroundColor: AppColors.primaryblack,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: Text(
              'Back to Dashboard',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
