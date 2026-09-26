import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_swipe/src/core/theme/app_colors.dart';
import 'package:vibe_swipe/src/core/utils/app_extensions.dart';
import 'package:vibe_swipe/src/modules/listner/performances/domain/entities/live_chat_message.dart';

class SuperChatTicker extends StatefulWidget {
  final List<LiveChatMessage> pinnedSuperChats;
  final Function(String messageId) onDismiss;

  const SuperChatTicker({
    super.key,
    required this.pinnedSuperChats,
    required this.onDismiss,
  });

  @override
  State<SuperChatTicker> createState() => _SuperChatTickerState();
}

class _SuperChatTickerState extends State<SuperChatTicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pinnedSuperChats.isEmpty) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: 70.h,
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: widget.pinnedSuperChats.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (context, index) {
            final message = widget.pinnedSuperChats[index];
            return _PinnedSuperChatCard(
              message: message,
              onDismiss: () => widget.onDismiss(message.id),
            );
          },
        ),
      ),
    );
  }
}

class _PinnedSuperChatCard extends StatefulWidget {
  final LiveChatMessage message;
  final VoidCallback onDismiss;

  const _PinnedSuperChatCard({
    required this.message,
    required this.onDismiss,
  });

  @override
  State<_PinnedSuperChatCard> createState() => _PinnedSuperChatCardState();
}

class _PinnedSuperChatCardState extends State<_PinnedSuperChatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _timerController;
  late Animation<double> _progressAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    final duration = Duration(seconds: widget.message.tierDurationSeconds);
    _timerController = AnimationController(
      duration: duration,
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _timerController, curve: Curves.linear),
    );
    _timerController.forward();
    _dismissTimer = Timer(duration, () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _timerController.dispose();
    super.dispose();
  }

  List<Color> _getTierColors() {
    switch (widget.message.tier) {
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

  @override
  Widget build(BuildContext context) {
    final colors = _getTierColors();

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          width: 240.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14.r,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        backgroundImage: widget.message.senderAvatar.isNotEmpty
                            ? NetworkImage(widget.message.senderAvatar)
                            : null,
                        child: widget.message.senderAvatar.isEmpty
                            ? Text(
                                widget.message.senderName.isNotEmpty
                                    ? widget.message.senderName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                      ),
                      8.pw,
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.message.senderName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                4.pw,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 1.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    '\$${widget.message.donationAmount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: colors.first,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            2.ph,
                            Text(
                              widget.message.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onDismiss,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, _) {
                  return LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 3.h,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
