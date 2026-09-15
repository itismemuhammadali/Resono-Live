import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/listener_create_post_controller.dart'
    show listenerCommunityControllerProvider, ListenerCommunityController;
import '../widgets/community_detail_post_tile.dart';
import '../widgets/community_detail_search_bar.dart';
import 'package:vibe_swipe/src/components/listener_tab_toggle.dart';

class ListenerGenreCommunityDetailView extends ConsumerWidget {
  const ListenerGenreCommunityDetailView({
    super.key,
    required this.communityName,
    required this.image,
    required this.members,
    required this.posts,
  });

  final String communityName;
  final String image;
  final String members;
  final String posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(listenerCommunityControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: SafeArea(
        child: Column(
          children: [
            ListenerPageHeader(title: communityName),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    20.ph,
                    const CommunityDetailSearchBar(),
                    16.ph,
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          ListenerCommunityController.filters.length,
                          (i) => Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: GenreChip(
                              label: ListenerCommunityController.filters[i],
                              isSelected: controller.selectedFilter == i,
                              onTap: () => controller.setFilter(i),
                            ),
                          ),
                        ),
                      ),
                    ),
                    16.ph,
                    ListenerTabToggle(
                      tabs: const [
                        ListenerTabItem(
                          label: 'Trending',
                          icon: Icons.trending_up_rounded,
                        ),
                        ListenerTabItem(
                          label: 'Latest',
                          icon: Icons.access_time_rounded,
                        ),
                      ],
                      selectedIndex: controller.isTrending ? 0 : 1,
                      onChanged: (i) => controller.setTrending(i == 0),
                      containerColor: AppColors.listenerBackButtonBorder,
                      showBorder: false,
                      containerRadius: 16,
                      tabRadius: 12,
                      tabVerticalPadding: 12,
                    ),
                    16.ph,
                    if (controller.posts.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.h),
                        child: Center(
                          child: Text(
                            'No discussions available right now.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.huegrey,
                            ),
                          ),
                        ),
                      )
                    else
                      ...controller.posts.map(
                        (p) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: CommunityDetailPostTile(
                            title: p.title,
                            author: p.authorName,
                            timeAgo: p.date,
                            replies: p.comments,
                            likes: p.likes,
                            pinned: false,
                            onTap: () => AppRouterGo.push(
                              listenerDiscussionDetailView,
                              extra: {
                                'postId': p.id,
                                'authorId': p.authorId,
                                'title': p.title,
                                'tag': p.category,
                                'author': p.authorName,
                                'timeAgo': p.date,
                                'replies': p.comments,
                                'likes': p.likes,
                                'body': p.content,
                                'authorAvatarUrl': p.authorAvatarUrl,
                              },
                            ),
                          ),
                        ),
                      ),
                    32.ph,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
