import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibe_swipe/src/core/services/community_firestore_service.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/performance_trending_entity.dart';
import 'performances_section_title.dart';

class PerformancesTrendingSection extends StatelessWidget {
  const PerformancesTrendingSection({super.key, required this.performances});

  final List<PerformanceTrendingEntity> performances;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PerformancesSectionTitle(
          image: 'assets/icons/png/home_trending_filter_icn.png',
          title: 'Trending Now',
        ),
        16.ph,
        _TrendingGrid(performances: performances),
      ],
    );
  }
}

class _TrendingGrid extends StatelessWidget {
  const _TrendingGrid({required this.performances});

  final List<PerformanceTrendingEntity> performances;

  @override
  Widget build(BuildContext context) {
    if (performances.isEmpty) {
      return const SizedBox.shrink();
    }

    final rows = <Widget>[];
    for (var i = 0; i < performances.length; i += 2) {
      final left = performances[i];
      final right = i + 1 < performances.length ? performances[i + 1] : null;

      rows.add(
        Row(
          children: [
            Expanded(child: _TrendingCard(performance: left)),
            16.pw,
            Expanded(
              child: right != null
                  ? _TrendingCard(performance: right)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );

      if (i + 2 < performances.length) rows.add(16.ph);
    }
    return Column(children: rows);
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.performance});

  final PerformanceTrendingEntity performance;

  void _onTap(BuildContext context) async {
    String postId = '';
    final perfId = performance.id;
    if (perfId.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? '';
      final authorName = user?.displayName ?? 'Listener';
      postId = await CommunityFirestoreService.findOrCreatePerformanceDiscussion(
        performanceId: perfId,
        performanceTitle: performance.title,
        authorId: uid,
        authorName: authorName,
        authorRole: 'listener',
      );
    }

    if (!context.mounted) return;

    AppRouterGo.push(
      listenerDiscussionDetailView,
      extra: {
        'title': performance.title,
        'author': performance.artist,
        'authorId': performance.artistId,
        'timeAgo': 'Now',
        'tag': 'Trending',
        'replies': 0,
        'likes': 0,
        'body': 'Discussion about ${performance.title}',
        'authorAvatarUrl': null,
        'postId': postId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.listenerChipBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.listenerBackButtonBorder,
            width: 1.09.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              child: SizedBox(
                height: 120.h,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NetworkSnap(
                      imageUrl: performance.thumbnailUrl,
                      width: 1.sw,
                      height: 120.h,
                      fit: BoxFit.cover,
                      radius: 0,
                      errorWidget: (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2B1055), Color(0xFF7597DE)],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: _ViewCountBadge(count: performance.views),
                    ),
                    Center(
                      child: Image.asset(
                        'assets/icons/png/performances_play_icn.png',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    performance.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryWhite,
                    ),
                  ),
                  3.ph,
                  Text(
                    performance.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryWhite.withValues(alpha: 0.55),
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

class _ViewCountBadge extends StatelessWidget {
  const _ViewCountBadge({required this.count});

  final String count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primaryblack.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(600.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_outlined,
            color: AppColors.primaryWhite,
            size: 14.sp,
          ),
          5.pw,
          Text(
            count,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryWhite,
            ),
          ),
        ],
      ),
    );
  }
}
