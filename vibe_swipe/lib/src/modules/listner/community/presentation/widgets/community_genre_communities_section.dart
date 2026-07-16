import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/modules/listner/community/domain/entities/community_entities.dart';
import 'community_section_title.dart';

class CommunityGenreCommunitiesSection extends StatelessWidget {
  const CommunityGenreCommunitiesSection({super.key, required this.communities});

  final List<GenreCommunity> communities;

  @override
  Widget build(BuildContext context) {
    if (communities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommunitySectionTitle(
          icon: Icons.people_alt_outlined,
          title: 'Genre Communities',
        ),
        16.ph,
        ...communities.map(
          (c) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _GenreCommunityTile(community: c),
          ),
        ),
      ],
    );
  }
}

class _GenreCommunityTile extends StatelessWidget {
  const _GenreCommunityTile({required this.community});
  final GenreCommunity community;

  IconData _iconForCategory(String name) {
    if (name.toLowerCase().contains('electronic') || name.toLowerCase().contains('production')) {
      return Icons.piano_rounded;
    }
    if (name.toLowerCase().contains('hip hop') || name.toLowerCase().contains('beat')) {
      return Icons.mic_external_on_rounded;
    }
    if (name.toLowerCase().contains('pop')) {
      return Icons.music_note_rounded;
    }
    return Icons.headphones_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRouterGo.push(
        listenerGenreCommunityDetailView,
        extra: {
          'communityName': community.name,
          'image': '',
          'members': '${community.memberCount}',
          'posts': '${community.postCount}',
        },
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.listenerChipBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.listenerBackButtonBorder,
            width: 1.09.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.listenerBackButtonBorder,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                _iconForCategory(community.name),
                color: AppColors.listenerYellow,
                size: 28.sp,
              ),
            ),
            16.pw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    community.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryWhite,
                    ),
                  ),
                  4.ph,
                  Row(
                    children: [
                      Image.asset('assets/icons/png/community_person_icn.png'),
                      6.pw,
                      Text(
                        '${community.memberCount} members',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.coolGray,
                        ),
                      ),
                      12.pw,
                      Image.asset('assets/icons/png/community_comment_icn.png'),
                      6.pw,
                      Text(
                        '${community.postCount} posts',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.coolGray,
                        ),
                      ),
                    ],
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
