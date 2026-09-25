import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_swipe/src/core/theme/app_colors.dart';
import 'package:vibe_swipe/src/core/utils/app_extensions.dart';
import 'package:vibe_swipe/src/modules/listner/performances/domain/entities/live_chat_message.dart';

class LiveChatMessageBubble extends StatelessWidget {
  final LiveChatMessage message;

  const LiveChatMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isSuperChat) {
      return _buildSuperChatBubble();
    }
    return _buildRegularBubble();
  }

  List<Color> _getTierColors() {
    switch (message.tier) {
      case SuperChatTier.platinum:
        return [AppColors.superChatPlatinumStart, AppColors.superChatPlatinumEnd];
      case SuperChatTier.gold:
        return [AppColors.superChatGoldStart, AppColors.superChatGoldEnd];
      case SuperChatTier.silver:
        return [AppColors.superChatSilverStart, AppColors.superChatSilverEnd];
      case SuperChatTier.bronze:
        return [AppColors.superChatBronzeStart, AppColors.superChatBronzeEnd];
    }
  }

  Widget _buildSuperChatBubble() {
    final colors = _getTierColors();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: colors.first,
          width: 1.2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12.r,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  backgroundImage: message.senderAvatar.isNotEmpty
                      ? NetworkImage(message.senderAvatar)
                      : null,
                  child: message.senderAvatar.isEmpty
                      ? Text(
                          message.senderName.isNotEmpty
                              ? message.senderName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                8.pw,
                Expanded(
                  child: Text(
                    message.senderName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: colors.first, size: 12.sp),
                      3.pw,
                      Text(
                        '\$${message.donationAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: colors.first,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Text(
              message.text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularBubble() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3.h, horizontal: 12.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12.r,
            backgroundImage: message.senderAvatar.isNotEmpty
                ? NetworkImage(message.senderAvatar)
                : null,
            backgroundColor: AppColors.listenerAvatarBg,
            child: message.senderAvatar.isEmpty
                ? Text(
                    message.senderName.isNotEmpty
                        ? message.senderName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryWhite,
                    ),
                  )
                : null,
          ),
          8.pw,
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(14.r),
                  bottomLeft: Radius.circular(14.r),
                  bottomRight: Radius.circular(14.r),
                ),
                border: Border.all(
                  color: AppColors.primaryWhite.withValues(alpha: 0.05),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.senderName,
                    style: TextStyle(
                      color: AppColors.listenerYellow,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  3.ph,
                  Text(
                    message.text,
                    style: TextStyle(
                      color: AppColors.primaryWhite,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SuperChatAnimatedBubble extends StatefulWidget {
  final LiveChatMessage message;
  final Widget child;
  final VoidCallback? onComplete;

  const SuperChatAnimatedBubble({
    super.key,
    required this.message,
    required this.child,
    this.onComplete,
  });

  @override
  State<SuperChatAnimatedBubble> createState() => _SuperChatAnimatedBubbleState();
}

class _SuperChatAnimatedBubbleState extends State<SuperChatAnimatedBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
