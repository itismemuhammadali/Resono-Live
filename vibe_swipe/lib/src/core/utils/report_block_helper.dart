import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibe_swipe/src/core/theme/app_colors.dart';

class ReportBlockHelper {
  static void showReportDialog(
    BuildContext context, {
    required String contentType,
    required String contentId,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text('Report $contentType'),
        message: const Text('Why are you reporting this content?'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => _handleReportSubmitted(ctx, 'Inappropriate Content'),
            child: const Text('Inappropriate Content'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => _handleReportSubmitted(ctx, 'Spam or Scam'),
            child: const Text('Spam or Scam'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => _handleReportSubmitted(ctx, 'Harassment or Bullying'),
            child: const Text('Harassment or Bullying'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => _handleReportSubmitted(ctx, 'Hate Speech'),
            child: const Text('Hate Speech'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  static void _handleReportSubmitted(BuildContext context, String reason) {
    Navigator.pop(context);
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Report Submitted'),
        content: Text(
          'Thank you for bringing this to our attention. Our safety team will review this report within 24 hours.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  static void showBlockUserDialog(
    BuildContext context, {
    required String username,
  }) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Block $username?'),
        content: Text(
          'They will not be able to see your profile, posts, or streams. You can unblock them anytime from Settings.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              showCupertinoDialog(
                context: context,
                builder: (c) => CupertinoAlertDialog(
                  title: const Text('User Blocked'),
                  content: Text('$username has been blocked.'),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('OK'),
                      onPressed: () => Navigator.pop(c),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  static void showPostOptionsModal(
    BuildContext context, {
    required String authorName,
    required String postId,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text('Options for post by $authorName'),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              showReportDialog(context, contentType: 'Post', contentId: postId);
            },
            child: const Text('Report Post'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              showBlockUserDialog(context, username: authorName);
            },
            child: Text('Block $authorName'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
