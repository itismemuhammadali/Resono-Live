import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vibe_swipe/src/core/theme/app_colors.dart';
import '../controllers/live_chat_controller.dart';
import 'live_chat_message_bubble.dart';

class LiveChatMessagesList extends ConsumerWidget {
  final String performanceId;

  const LiveChatMessagesList({super.key, required this.performanceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatController = ref.watch(liveChatControllerProvider(performanceId));

    if (chatController.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.listenerYellow,
          strokeWidth: 2,
        ),
      );
    }

    if (chatController.messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet.\nBe the first to say something!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14.sp,
            color: AppColors.primaryWhite.withValues(alpha: 0.4),
          ),
        ),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: chatController.messages.length,
      itemBuilder: (context, index) {
        final message = chatController.messages[index];
        if (message.isSuperChat) {
          return SuperChatAnimatedBubble(
            message: message,
            child: LiveChatMessageBubble(message: message),
          );
        }
        return LiveChatMessageBubble(message: message);
      },
    );
  }
}
