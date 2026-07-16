import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../../home/presentation/widgets/artist_home_app_bar.dart';
import '../controller/artist_community_controller.dart';
import '../widgets/artist_community_recent_activity_section.dart';
import '../widgets/artist_community_trending_discussions_section.dart';
import '../widgets/artist_community_trending_topics_section.dart';
import '../widgets/artist_community_your_posts_section.dart';

class ArtistCommunityView extends ConsumerWidget {
  const ArtistCommunityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(artistCommunityControllerProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArtistHomeAppBar(artistName: controller.artistName),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.ph,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Community',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryWhite,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            AppRouterGo.push(artistCreatePostView),
                        child: Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: const BoxDecoration(
                            color: AppColors.listenerYellow,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  16.ph,
                  if (controller.isLoadingPosts)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: CircularProgressIndicator(
                          color: AppColors.listenerActiveTab,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  else if (controller.yourPosts.isNotEmpty)
                    ArtistCommunityYourPostsSection(posts: controller.yourPosts),
                  16.ph,
                  if (controller.trendingDiscussions.isNotEmpty)
                    ArtistCommunityTrendingDiscussionsSection(
                      discussions: controller.trendingDiscussions,
                    ),
                  16.ph,
                  if (controller.trendingTopics.isNotEmpty)
                    ArtistCommunityTrendingTopicsSection(
                      topics: controller.trendingTopics,
                    ),
                  16.ph,
                  if (controller.recentActivity.isNotEmpty)
                    ArtistCommunityRecentActivitySection(
                      activities: controller.recentActivity,
                    ),
                  32.ph,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
