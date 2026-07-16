import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/listener_create_post_controller.dart';
import '../widgets/discussion_original_post.dart';
import '../widgets/discussion_reply_card.dart';
import '../widgets/discussion_reply_input.dart';

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
        controller.initDiscussion(widget.postId!);
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

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(listenerCommunityControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: SafeArea(
        child: Column(
          children: [
            const ListenerPageHeader(title: 'Discussion'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    20.ph,
                    DiscussionOriginalPost(
                      title: widget.title,
                      author: widget.author,
                      timeAgo: widget.timeAgo,
                      tag: widget.tag,
                      replies: controller.discussionComments.length,
                      likes: controller.discussionLikeCount,
                      body: widget.body,
                      authorAvatarUrl: widget.authorAvatarUrl,
                      isLiked: controller.isDiscussionLiked,
                      onLikeTap: () => controller.toggleDiscussionLike(),
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
