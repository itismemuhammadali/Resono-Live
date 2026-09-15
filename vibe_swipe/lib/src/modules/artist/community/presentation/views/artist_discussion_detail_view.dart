import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controller/artist_discussion_detail_controller.dart';
import '../widgets/artist_discussion_detail_header.dart';
import '../widgets/artist_discussion_detail_post_card.dart';
import '../widgets/artist_discussion_detail_reply_tile.dart';
import '../widgets/artist_post_detail_comment_input.dart';
import 'package:vibe_swipe/src/core/utils/report_block_helper.dart';

class ArtistDiscussionDetailView extends ConsumerStatefulWidget {
  const ArtistDiscussionDetailView({super.key, required this.discussion});

  final Map<String, dynamic> discussion;

  @override
  ConsumerState<ArtistDiscussionDetailView> createState() =>
      _ArtistDiscussionDetailViewState();
}

class _ArtistDiscussionDetailViewState
    extends ConsumerState<ArtistDiscussionDetailView> {
  final _commentController = TextEditingController();

  String get _postId => (widget.discussion['id'] as String?) ?? '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    ref.read(artistDiscussionDetailControllerProvider(_postId).notifier).postComment(text);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(artistDiscussionDetailControllerProvider(_postId));

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/png/app_background_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ArtistDiscussionDetailHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ArtistDiscussionDetailPostCard(
                        discussion: widget.discussion,
                        isLiked: controller.isLiked,
                        likeCount: controller.likeCount,
                        commentCount: controller.comments.length,
                        onLikeTap: () => controller.toggleLike(),
                        onBlockComplete: () => Navigator.maybePop(context),
                      ),
                      24.ph,
                      Text(
                        'Comments (${controller.comments.length})',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryWhite,
                        ),
                      ),
                      12.ph,
                      ...controller.comments.map(
                        (comment) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: ArtistDiscussionDetailReplyTile(
                            reply: {
                              'author': comment.authorName,
                              'date': comment.timeAgo,
                              'text': comment.text,
                              'likes': comment.likesCount,
                              'authorAvatarUrl': comment.authorAvatarUrl,
                            },
                            isLiked: controller.isCommentLiked(comment.id),
                            onLikeTap: () => controller.toggleCommentLike(comment.id),
                            onOptionsTap: () {
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
                      ArtistPostDetailCommentInput(
                        controller: _commentController,
                        onSubmit: _submitComment,
                      ),
                      20.ph,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
