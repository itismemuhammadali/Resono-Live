import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/modules/listner/community/domain/entities/community_entities.dart';
import '../controllers/listener_create_post_controller.dart';
import '../widgets/community_header.dart';
import '../widgets/community_featured_section.dart';
import '../widgets/community_genre_communities_section.dart';
import '../widgets/community_trending_section.dart';
import '../widgets/community_new_releases_section.dart';
import '../../../../../components/meta_ad_placement_widget.dart';

class ListenerCommunityView extends ConsumerWidget {
  const ListenerCommunityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(listenerCommunityControllerProvider);

    final genres = CommunityDerivedData.genreCommunities(controller.allPosts);
    final newReleases = CommunityDerivedData.newReleases(controller.allPosts);
    final featured = controller.allPosts.isNotEmpty ? controller.allPosts.first : null;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommunityHeader(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  24.ph,
                  if (controller.recentPosts.isNotEmpty) ...[
                    Text(
                      'Community Buzz',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryWhite,
                      ),
                    ),
                    12.ph,
                    ...controller.recentPosts.map(
                      (post) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: GestureDetector(
                          onTap: () => AppRouterGo.push(
                            listenerDiscussionDetailView,
                            extra: {
                              'postId': post.id,
                              'authorId': post.authorId,
                              'title': post.title,
                              'tag': post.category,
                              'author': post.authorName,
                              'timeAgo': post.date,
                              'replies': post.comments,
                              'likes': post.likes,
                              'body': post.content,
                              'authorAvatarUrl': post.authorAvatarUrl,
                            },
                          ),
                          child: _RecentPostCard(post: post),
                        ),
                      ),
                    ),
                    24.ph,
                  ],
                  CommunityFeaturedSection(post: featured),
                  24.ph,
                  const MetaAdPlacementWidget(
                    type: MetaAdPlacementType.inlineFeed,
                    placementName: 'Community Feed',
                    isTestMode: true,
                  ),
                  24.ph,
                  CommunityGenreCommunitiesSection(communities: genres),
                  24.ph,
                  CommunityTrendingSection(posts: controller.allPosts),
                  24.ph,
                  CommunityNewReleasesSection(posts: newReleases),
                  32.ph,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentPostCard extends StatelessWidget {
  const _RecentPostCard({required this.post});
  final dynamic post;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.listenerChipBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (post.authorAvatarUrl != null && (post.authorAvatarUrl as String).isNotEmpty)
                ClipOval(
                  child: NetworkSnap(
                    imageUrl: post.authorAvatarUrl as String,
                    width: 28.w,
                    height: 28.w,
                    fit: BoxFit.cover,
                    borderRadiusGeometry: BorderRadius.circular(14.w),
                  ),
                )
              else
                Icon(
                  post.authorRole == 'artist'
                      ? Icons.person_rounded
                      : Icons.headphones_rounded,
                  size: 16.sp,
                  color: AppColors.listenerYellow,
                ),
              8.pw,
              Text(
                post.authorName,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.listenerYellow,
                ),
              ),
              const Spacer(),
              Text(
                post.date,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12.sp,
                  color: AppColors.santagrey,
                ),
              ),
            ],
          ),
          8.ph,
          Text(
            post.title,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryWhite,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
