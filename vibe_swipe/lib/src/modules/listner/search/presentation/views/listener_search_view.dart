import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/modules/listner/profile/data/dtos/artist_dto.dart';
import '../controllers/listener_search_controller.dart';
import '../widgets/search_input_bar.dart';
import '../widgets/search_recent_section.dart';
import '../widgets/search_trending_genres_section.dart';
import '../widgets/search_trending_artists_section.dart';

class ListenerSearchView extends ConsumerWidget {
  const ListenerSearchView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(listenerSearchControllerProvider);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(20.r),
                  bottomLeft: Radius.circular(20.r),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.snowWhite.withValues(alpha: 0.4),
                    width: 1.w,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryWhite,
                    ),
                  ),
                  16.ph,
                  SearchInputBar(
                    controller: controller.searchTextController,
                  ),
                  4.ph,
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.isLoading) ...[
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.h),
                        child: CircularProgressIndicator(
                          color: AppColors.listenerActiveTab,
                        ),
                      ),
                    ),
                  ] else if (controller.hasSearched) ...[
                    if (controller.searchResults.isNotEmpty) ...[
                      Text(
                        'Search Results',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryWhite,
                        ),
                      ),
                      12.ph,
                      ...List.generate(
                        controller.searchResults.length,
                        (i) {
                          final result = controller.searchResults[i];
                          final isArtist = result.genre.isNotEmpty;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: _SearchResultCard(
                              uid: result.uid,
                              name: result.name,
                              genre: result.genre,
                              profileImageUrl: result.profileImageUrl,
                              isArtist: isArtist,
                              onTap: isArtist
                                  ? () => AppRouterGo.push(
                                        artistProfileView,
                                        extra: ArtistProfileArgs(
                                          artistId: result.uid,
                                          artistName: result.name,
                                        ),
                                      )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.h),
                          child: Text(
                            'No results found',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.santagrey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ] else ...[
                    if (controller.recentSearches.isNotEmpty) ...[
                      SearchRecentSection(
                        items: controller.recentSearches,
                        onItemTap: controller.onRecentSearchTap,
                      ),
                      24.ph,
                    ],
                    SearchTrendingGenresSection(
                      genres: controller.trendingGenres,
                      selectedGenre: controller.selectedGenre,
                      onGenreTap: controller.onGenreSelected,
                    ),
                    24.ph,
                    SearchTrendingArtistsSection(
                      artists: controller.trendingArtists,
                      onArtistTap: (uid, name) => AppRouterGo.push(
                        artistProfileView,
                        extra: ArtistProfileArgs(
                          artistId: uid,
                          artistName: name,
                        ),
                      ),
                    ),
                    16.ph,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.uid,
    required this.name,
    required this.genre,
    required this.isArtist,
    this.profileImageUrl = '',
    this.onTap,
  });

  final String uid;
  final String name;
  final String genre;
  final bool isArtist;
  final String profileImageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.listenerChipBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.listenerChipBorder),
        ),
        child: Row(
          children: [
            if (profileImageUrl.isNotEmpty)
              ClipOval(
                child: NetworkSnap(
                  imageUrl: profileImageUrl,
                  width: 34.w,
                  height: 34.w,
                  fit: BoxFit.cover,
                  borderRadiusGeometry: BorderRadius.circular(17.w),
                ),
              )
            else
              Icon(
                isArtist ? Icons.person : Icons.account_circle,
                color: AppColors.santagrey,
                size: 24.sp,
              ),
            14.pw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryWhite,
                    ),
                  ),
                  if (genre.isNotEmpty) ...[
                    3.ph,
                    Text(
                      genre,
                      style: TextStyle(fontSize: 12.sp, color: AppColors.santagrey),
                    ),
                  ],
                ],
              ),
            ),
            if (isArtist)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.listenerActiveTab.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Artist',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.listenerActiveTab,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
