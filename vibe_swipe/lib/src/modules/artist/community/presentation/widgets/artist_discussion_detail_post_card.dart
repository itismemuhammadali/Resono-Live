import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/core/utils/report_block_helper.dart';

class ArtistDiscussionDetailPostCard extends StatelessWidget {
  const ArtistDiscussionDetailPostCard({
    super.key,
    required this.discussion,
    this.isLiked = false,
    this.likeCount,
    this.commentCount,
    this.onLikeTap,
    this.onBlockComplete,
  });

  final Map<String, dynamic> discussion;
  final bool isLiked;
  final int? likeCount;
  final int? commentCount;
  final VoidCallback? onLikeTap;
  final VoidCallback? onBlockComplete;

  @override
  Widget build(BuildContext context) {
    final author = discussion['author'] as String;
    final date = discussion['date'] as String;
    final time = (discussion['time'] as String?) ?? '';
    final title = discussion['title'] as String;
    final likes = likeCount ?? (discussion['likes'] as int?) ?? 0;
    final comments = commentCount ?? (discussion['replies'] as int?) ?? 0;
    final authorAvatarUrl = (discussion['authorAvatarUrl'] as String?) ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryWhite.withValues(alpha: 0.10),
          width: 1.09.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 48.w,
                height: 48.w,
                child: authorAvatarUrl.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: authorAvatarUrl,
                          width: 48.w,
                          height: 48.w,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => CircleAvatar(
                            radius: 24.r,
                            backgroundColor: AppColors.listenerYellow.withValues(alpha: 0.20),
                            child: Image.asset(
                              'assets/icons/png/artist_community_trending_discussions.png',
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 48.w,
                            height: 48.w,
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            decoration: BoxDecoration(
                              color: AppColors.listenerYellow.withValues(alpha: 0.20),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/icons/png/artist_community_trending_discussions.png',
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: 48.w,
                        height: 48.w,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: AppColors.listenerYellow.withValues(alpha: 0.20),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/icons/png/artist_community_trending_discussions.png',
                        ),
                      ),
              ),
              12.pw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryWhite,
                      ),
                    ),
                    4.ph,
                    Text(
                      time.isNotEmpty ? '$date at $time' : date,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.huegrey,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  final postId = (discussion['id'] as String?) ?? '';
                  final authorId = discussion['authorId'] as String?;
                  ReportBlockHelper.showPostOptionsModal(
                    context,
                    authorName: author.isNotEmpty ? author : 'User',
                    postId: postId,
                    authorId: authorId,
                    onBlockComplete: onBlockComplete,
                    onReportComplete: () => Navigator.maybePop(context),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Icon(
                    Icons.more_vert,
                    size: 22.sp,
                    color: AppColors.huegrey,
                  ),
                ),
              ),
            ],
          ),
          16.ph,
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryWhite,
            ),
          ),
          10.ph,
          Row(
            children: [
              GestureDetector(
                onTap: onLikeTap,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      isLiked ? AppColors.listenerLiveRed : Colors.white,
                      BlendMode.srcIn,
                    ),
                  child: Image.asset(
                    'assets/icons/png/artist_community_post_like_btn_icn.png',
                  ),
                ),
              ),
              6.pw,
              Text(
                '$likes',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isLiked ? AppColors.listenerLiveRed : AppColors.coolGray,
                ),
              ),
              20.pw,
              Image.asset('assets/icons/png/community_comment_icn.png'),
              6.pw,
              Text(
                '$comments comments',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.coolGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
