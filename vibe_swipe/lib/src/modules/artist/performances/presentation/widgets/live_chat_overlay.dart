import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_swipe/src/core/theme/app_colors.dart';
import 'package:vibe_swipe/src/core/services/live_chat_service.dart';
import 'package:vibe_swipe/src/modules/listner/performances/domain/entities/live_chat_message.dart';
import 'package:vibe_swipe/src/core/utils/app_extensions.dart';

class LiveChatOverlay extends StatelessWidget {
  final String performanceId;
  /// Distance from the bottom of the screen. Default 100 works for the
  /// listener side. Pass a larger value on the artist side to clear the
  /// mic/cam/flip buttons row.
  final double bottomOffset;

  const LiveChatOverlay({
    super.key,
    required this.performanceId,
    this.bottomOffset = 100,
  });

  @override
  Widget build(BuildContext context) {
    final overlayHeight = (MediaQuery.of(context).size.height * 0.25).clamp(120.0, 280.0);

    return Positioned(
      left: 12.w,
      right: 12.w,
      bottom: bottomOffset.h,
      height: overlayHeight,
      child: StreamBuilder<List<LiveChatMessage>>(
        stream: LiveChatService.watchMessagesForOverlay(performanceId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return SizedBox.shrink();
          }
          final messages = snapshot.data!;
          return ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return _ChatOverlayMessage(message: messages[index]);
            },
          );
        },
      ),
    );
  }
}

class _ChatOverlayMessage extends StatelessWidget {
  final LiveChatMessage message;
  const _ChatOverlayMessage({required this.message});

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

  @override
  Widget build(BuildContext context) {
    if (message.isSuperChat) {
      final colors = _getTierColors();
      return Container(
        margin: EdgeInsets.only(bottom: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 10.r,
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
                        fontSize: 9.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
            6.pw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          message.senderName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      4.pw,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '\$${message.donationAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: colors.first,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primaryblack.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        '${message.senderName}: ${message.text}',
        style: TextStyle(
          color: AppColors.primaryWhite.withValues(alpha: 0.8),
          fontSize: 12.sp,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
