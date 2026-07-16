import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/core/services/community_firestore_service.dart';
import '../../../profile/data/dtos/artist_dto.dart';

class UpcomingPerformanceQuickActionsSection extends StatelessWidget {
  const UpcomingPerformanceQuickActionsSection({
    super.key,
    required this.artist,
    required this.artistId,
    required this.performanceId,
    required this.performanceTitle,
  });

  final String artist;
  final String artistId;
  final String performanceId;
  final String performanceTitle;

  void _viewArtistProfile(BuildContext context) {
    AppRouterGo.push(
      artistProfileView,
      extra: ArtistProfileArgs(
        artistId: artistId,
        artistName: artist,
      ),
    );
  }

  Future<void> _joinDiscussion(BuildContext context) async {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid == null) return;

    final data = await locator<FirestoreService>().getUserData(uid);
    final authorName = (data?['username'] ?? data?['name'] ?? 'Listener').toString();
    final authorRole = (data?['role'] ?? 'listener').toString();
    final authorAvatarUrl = (data?['profileImageUrl'] ?? data?['avatarUrl'] ?? '').toString();

    final postId = await CommunityFirestoreService.findOrCreatePerformanceDiscussion(
      performanceId: performanceId,
      performanceTitle: performanceTitle,
      authorId: uid,
      authorName: authorName,
      authorRole: authorRole,
      authorAvatarUrl: authorAvatarUrl,
    );

    if (!context.mounted) return;

    AppRouterGo.push(
      listenerDiscussionDetailView,
      extra: {
        'title': '$performanceTitle — Discussion',
        'author': artist,
        'timeAgo': 'now',
        'tag': 'Performance Discussion',
        'replies': 0,
        'likes': 0,
        'body': 'Join the discussion about this performance!',
        'authorAvatarUrl': '',
        'postId': postId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryWhite,
          ),
        ),
        14.ph,
        _QuickActionCard(
          icon: Icons.person_outline_rounded,
          title: 'View Artist Profile',
          subtitle: artist,
          onTap: () => _viewArtistProfile(context),
        ),
        10.ph,
        _QuickActionCard(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Join Discussion',
          subtitle: 'Talk about this performance',
          onTap: () => _joinDiscussion(context),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF121821),
          borderRadius: BorderRadius.circular(16.r),
          border: Border(
            top: BorderSide(color: const Color(0xFF1F2937), width: 1.09.w),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppColors.listenerYellow, size: 20.sp),
            ),
            16.pw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryWhite,
                    ),
                  ),
                  4.ph,
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryWhite.withValues(alpha: 0.50),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.primaryWhite.withValues(alpha: 0.4), size: 24.sp),
          ],
        ),
      ),
    );
  }
}
