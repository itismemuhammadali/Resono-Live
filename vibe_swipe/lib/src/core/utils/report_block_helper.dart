import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibe_swipe/src/core/services/safety_service.dart';
import 'package:vibe_swipe/src/core/services/community_firestore_service.dart';

class ReportBlockHelper {
  /// Shows options (Report & 7-Day Ban, or Permanently Block) for a comment
  static void showCommentOptionsModal(
    BuildContext context, {
    required String authorId,
    required String authorName,
    required String commentId,
    required String commentText,
    String? artistId,
    VoidCallback? onActionComplete,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text('Options for comment by $authorName'),
        message: Text(
          commentText.length > 60 ? '"${commentText.substring(0, 60)}..."' : '"$commentText"',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              _showReportCommentDialog(
                context,
                authorId: authorId,
                authorName: authorName,
                commentId: commentId,
                commentText: commentText,
                artistId: artistId,
                onComplete: onActionComplete,
              );
            },
            child: const Text('Report & Shadow-Ban (7 Days)'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              showBlockUserDialog(
                context,
                targetUserId: authorId,
                targetUsername: authorName,
                onBlockComplete: onActionComplete,
              );
            },
            child: Text('Block $authorName Permanently'),
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

  static void _showReportCommentDialog(
    BuildContext context, {
    required String authorId,
    required String authorName,
    required String commentId,
    required String commentText,
    String? artistId,
    VoidCallback? onComplete,
  }) {
    const reasons = [
      'Inappropriate Content',
      'Harassment or Bullying',
      'Spam or Scam',
      'Hate Speech',
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Report Comment'),
        message: const Text(
          'Select a reason. The user will be reported and shadow-banned from your performances and posts for 7 days.',
        ),
        actions: reasons.map((reason) {
          return CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await SafetyService.reportCommentAndShadowBan(
                  reportedUserId: authorId,
                  reportedUserName: authorName,
                  commentId: commentId,
                  commentText: commentText,
                  reason: reason,
                  artistId: artistId,
                );
                if (context.mounted) {
                  showCupertinoDialog(
                    context: context,
                    builder: (alertCtx) => CupertinoAlertDialog(
                      title: const Text('Report Submitted'),
                      content: Text(
                        '$authorName has been reported and shadow-banned for 7 days. They will not be able to access your performances or posts.',
                      ),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.pop(alertCtx);
                            onComplete?.call();
                          },
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to submit report: $e')),
                  );
                }
              }
            },
            child: Text(reason),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  /// Shows options (Report Artist, Block Artist) from the Artist Profile view
  static void showArtistOptionsModal(
    BuildContext context, {
    required String artistId,
    required String artistName,
    VoidCallback? onArtistBlocked,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text('Options for $artistName'),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              _showReportArtistDialog(context, artistId: artistId, artistName: artistName);
            },
            child: const Text('Report Artist'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              showBlockUserDialog(
                context,
                targetUserId: artistId,
                targetUsername: artistName,
                isArtist: true,
                onBlockComplete: onArtistBlocked,
              );
            },
            child: Text('Block $artistName'),
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

  static void _showReportArtistDialog(
    BuildContext context, {
    required String artistId,
    required String artistName,
  }) {
    const reasons = [
      'Inappropriate Content',
      'Harassment or Bullying',
      'Spam or Scam',
      'Impersonation',
      'Hate Speech',
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text('Report $artistName'),
        message: const Text('Why are you reporting this artist?'),
        actions: reasons.map((reason) {
          return CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await SafetyService.reportArtist(
                  artistId: artistId,
                  artistName: artistName,
                  reason: reason,
                );
                if (context.mounted) {
                  showCupertinoDialog(
                    context: context,
                    builder: (alertCtx) => CupertinoAlertDialog(
                      title: const Text('Report Submitted'),
                      content: const Text(
                        'Thank you for bringing this to our attention. Our safety team will review this report within 24 hours.',
                      ),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(alertCtx),
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to submit report: $e')),
                  );
                }
              }
            },
            child: Text(reason),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  /// Shows confirmation dialog to permanently block a user or artist
  static void showBlockUserDialog(
    BuildContext context, {
    required String targetUserId,
    required String targetUsername,
    bool isArtist = false,
    VoidCallback? onBlockComplete,
  }) {
    final cleanId = targetUserId.trim();
    if (cleanId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to block user: User ID is missing.')),
      );
      return;
    }

    final currentUid = SafetyService.currentUserId;
    if (currentUid != null && cleanId == currentUid) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Action Not Allowed'),
          content: const Text('You cannot block your own account.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
      return;
    }

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Block $targetUsername?'),
        content: Text(
          isArtist
              ? 'You will not see performances, posts, or content from $targetUsername anymore.'
              : '$targetUsername will not be able to see your profile, posts, or live streams.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await SafetyService.blockUser(
                  targetUserId: cleanId,
                  targetUserName: targetUsername,
                );
                if (context.mounted) {
                  showCupertinoDialog(
                    context: context,
                    builder: (alertCtx) => CupertinoAlertDialog(
                      title: const Text('Blocked'),
                      content: Text('$targetUsername has been blocked.'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.pop(alertCtx);
                            onBlockComplete?.call();
                          },
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to block user: $e')),
                  );
                }
              }
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  /// Backward-compatible legacy helpers
  static void showReportDialog(
    BuildContext context, {
    required String contentType,
    required String contentId,
    String? authorId,
    String? authorName,
    VoidCallback? onReportComplete,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text('Report $contentType'),
        message: const Text('Why are you reporting this content?'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => _handleReportSubmitted(
              ctx,
              reason: 'Inappropriate Content',
              contentType: contentType,
              contentId: contentId,
              authorId: authorId,
              authorName: authorName,
              onComplete: onReportComplete,
            ),
            child: const Text('Inappropriate Content'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => _handleReportSubmitted(
              ctx,
              reason: 'Spam or Scam',
              contentType: contentType,
              contentId: contentId,
              authorId: authorId,
              authorName: authorName,
              onComplete: onReportComplete,
            ),
            child: const Text('Spam or Scam'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => _handleReportSubmitted(
              ctx,
              reason: 'Harassment or Bullying',
              contentType: contentType,
              contentId: contentId,
              authorId: authorId,
              authorName: authorName,
              onComplete: onReportComplete,
            ),
            child: const Text('Harassment or Bullying'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => _handleReportSubmitted(
              ctx,
              reason: 'Hate Speech',
              contentType: contentType,
              contentId: contentId,
              authorId: authorId,
              authorName: authorName,
              onComplete: onReportComplete,
            ),
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

  static void _handleReportSubmitted(
    BuildContext context, {
    required String reason,
    required String contentType,
    required String contentId,
    String? authorId,
    String? authorName,
    VoidCallback? onComplete,
  }) async {
    Navigator.pop(context);
    try {
      await SafetyService.reportContent(
        contentType: contentType,
        contentId: contentId,
        reason: reason,
        authorId: authorId,
        authorName: authorName,
      );
    } catch (e) {
      debugPrint('[ReportBlockHelper] Report error: $e');
    }
    if (context.mounted) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Report Submitted'),
          content: Text(
            contentType.toLowerCase() == 'post'
                ? 'Thank you. This post has been reported and hidden from your feed.'
                : 'Thank you for bringing this to our attention. Our safety team will review this report within 24 hours.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(ctx);
                onComplete?.call();
              },
            ),
          ],
        ),
      );
    }
  }

  static void showPostOptionsModal(
    BuildContext context, {
    required String authorName,
    required String postId,
    String? authorId,
    VoidCallback? onBlockComplete,
    VoidCallback? onReportComplete,
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
              showReportDialog(
                context,
                contentType: 'Post',
                contentId: postId,
                authorId: authorId,
                authorName: authorName,
                onReportComplete: onReportComplete,
              );
            },
            child: const Text('Report Post'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              final hasValidAuthorId = authorId != null && authorId.trim().isNotEmpty;
              if (hasValidAuthorId) {
                showBlockUserDialog(
                  context,
                  targetUserId: authorId.trim(),
                  targetUsername: authorName,
                  onBlockComplete: onBlockComplete,
                );
                return;
              }

              // If authorId is missing but postId is available, attempt to resolve it
              if (postId.trim().isNotEmpty) {
                try {
                  // Try to fetch post from Firestore
                  final doc = await CommunityFirestoreService.getPost(postId.trim());
                  if (context.mounted && doc != null && doc.authorId.trim().isNotEmpty) {
                    showBlockUserDialog(
                      context,
                      targetUserId: doc.authorId.trim(),
                      targetUsername: doc.authorName.isNotEmpty ? doc.authorName : authorName,
                      onBlockComplete: onBlockComplete,
                    );
                    return;
                  }
                } catch (_) {}
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cannot block $authorName: User information is unavailable.')),
                );
              }
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
