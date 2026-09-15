import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibe_swipe/src/core/services/community_firestore_service.dart';
import '../controllers/listener_create_post_controller.dart';
import '../widgets/discussion_original_post.dart';
import '../widgets/discussion_reply_card.dart';
import '../widgets/discussion_reply_input.dart';
import 'package:vibe_swipe/src/core/utils/report_block_helper.dart';

class ListenerDiscussionDetailView extends ConsumerStatefulWidget {
  const ListenerDiscussionDetailView({
    super.key,
    required this.title,
    required this.author,
    required this.timeAgo,
    required this.tag,
    required this.replies,
    required this.likes,
    required this.body,
    this.authorAvatarUrl,
    this.postId,
    this.authorId,
  });

  final String title;
  final String author;
  final String timeAgo;
  final String tag;
  final int replies;
  final int likes;
  final String body;
  final String? authorAvatarUrl;
  final String? postId;
  final String? authorId;

  @override
  ConsumerState<ListenerDiscussionDetailView> createState() =>
      _ListenerDiscussionDetailViewState();
}

class _ListenerDiscussionDetailViewState
    extends ConsumerState<ListenerDiscussionDetailView> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(listenerCommunityControllerProvider.notifier);
      if (widget.postId != null && widget.postId!.isNotEmpty) {
        controller.initDiscussion(widget.postId!, initialAvatar: widget.authorAvatarUrl ?? '');
      }

    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    ref.read(listenerCommunityControllerProvider.notifier).postDiscussionComment(text);
    _commentController.clear();
  }

  void _sharePost(BuildContext context, String currentTitle) {
    final postId = widget.postId ?? '';
    if (postId.isNotEmpty) {
      Share.share(
        "Check out this discussion on VibeSwipe: '$currentTitle'\n"
        "https://vibeswipe.page.link/discussion-detail?postId=$postId",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(listenerCommunityControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: SafeArea(
        child: Column(
          children: [
            ListenerPageHeader(
              title: 'Discussion',
              trailing: IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.primaryWhite),
                onPressed: () {
                  _sharePost(context, widget.title);
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    20.ph,
                    StreamBuilder<CommunityPost?>(
                      stream: controller.currentPostStream,
                      builder: (context, snapshot) {
                        final post = snapshot.data;
                        final displayTitle = post?.title ?? widget.title;
                        final displayBody = post?.content ?? widget.body;
                        final displayAuthor = post?.authorName ?? widget.author;
                        final displayTime = post?.timeAgo ?? widget.timeAgo;
                        final displayTag = post?.category ?? widget.tag;
                        final displayAvatar = (controller.discussionAuthorAvatar.isNotEmpty)
                            ? controller.discussionAuthorAvatar
                            : ((post?.authorAvatarUrl != null && post!.authorAvatarUrl.isNotEmpty)
                                ? post.authorAvatarUrl
                                : widget.authorAvatarUrl);


                        return DiscussionOriginalPost(
                          title: displayTitle,
                          author: displayAuthor,
                          timeAgo: displayTime,
                          tag: displayTag,
                          replies: controller.discussionComments.length,
                          likes: controller.discussionLikeCount,
                          body: displayBody,
                          authorAvatarUrl: displayAvatar,
                          isLiked: controller.isDiscussionLiked,
                          onLikeTap: () => controller.toggleDiscussionLike(),
                          onShareTap: () => _sharePost(context, displayTitle),
                          onOptionsTap: () {
                            final effectiveAuthorId = (post?.authorId != null && post!.authorId.trim().isNotEmpty)
                                ? post.authorId.trim()
                                : (widget.authorId != null && widget.authorId!.trim().isNotEmpty
                                    ? widget.authorId!.trim()
                                    : null);
                            final effectivePostId = (widget.postId != null && widget.postId!.trim().isNotEmpty)
                                ? widget.postId!.trim()
                                : (post?.id != null ? post!.id.trim() : '');

                            ReportBlockHelper.showPostOptionsModal(
                              context,
                              authorName: displayAuthor.isNotEmpty ? displayAuthor : 'User',
                              postId: effectivePostId,
                              authorId: effectiveAuthorId,
                              onBlockComplete: () => Navigator.maybePop(context),
                              onReportComplete: () => Navigator.maybePop(context),
                            );
                          },
                        );
                      },
                    ),
                    24.ph,
                    Text(
                      'Comments (${controller.discussionComments.length})',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryWhite,
                      ),
                    ),
                    12.ph,
                    if (controller.discussionComments.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Center(
                          child: Text(
                            'No comments yet. Be the first to respond!',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.huegrey,
                            ),
                          ),
                        ),
                      )
                    else
                      ...controller.discussionComments.map(
                        (comment) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: DiscussionReplyCard(
                            author: comment.authorName,
                            timeAgo: comment.timeAgo,
                            text: comment.text,
                            likes: comment.likesCount,
                            replyCount: 0,
                            avatarUrl: comment.authorAvatarUrl,
                            isLiked: controller.isCommentLiked(comment.id),
                            onLikeTap: () => controller.toggleCommentLike(comment.id),
                            onMoreTap: () {
                              ReportBlockHelper.showCommentOptionsModal(
                                context,
                                authorId: comment.authorId,
                                authorName: comment.authorName,
                                commentId: comment.id,
                                commentText: comment.text,
                              );
                            },
                          ),
                        ),
                      ),
                    20.ph,
                  ],
                ),
              ),
            ),
            DiscussionReplyInput(
              replyController: _commentController,
              onPost: _submitComment,
            ),
          ],
        ),
      ),
    );
  }
}
