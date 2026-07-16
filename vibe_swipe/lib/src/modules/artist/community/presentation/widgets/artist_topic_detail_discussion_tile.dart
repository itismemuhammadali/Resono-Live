import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class ArtistTopicDetailDiscussionTile extends StatelessWidget {
  const ArtistTopicDetailDiscussionTile({super.key, required this.discussion});

  final Map<String, dynamic> discussion;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRouterGo.push(artistDiscussionDetailView, extra: discussion),
      child: Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: AppColors.listenerYellow.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/icons/png/artist_community_trending_discussions.png',
            ),
          ),
          12.pw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  discussion['title'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryWhite,
                  ),
                ),
                4.ph,
                Text(
                  '${discussion['author']} · ${discussion['replies']} replies · ${discussion['date']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.huegrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
