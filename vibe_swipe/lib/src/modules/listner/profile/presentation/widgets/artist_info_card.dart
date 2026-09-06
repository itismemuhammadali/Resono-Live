import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import '../../data/dtos/artist_dto.dart';

class ArtistInfoCard extends StatelessWidget {
  const ArtistInfoCard({
    super.key,
    required this.artist,
    required this.isFollowing,
    required this.onFollow,
    this.performances = const [],
    this.onPerformancesTap,
    this.onOptionsTap,
  });

  final ArtistDto artist;
  final bool isFollowing;
  final VoidCallback onFollow;
  final List<Map<String, dynamic>> performances;
  final VoidCallback? onPerformancesTap;
  final VoidCallback? onOptionsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.listenerChipBorder, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ArtistAvatar(artist: artist),
              16.pw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.name,
                      style: TextStyle(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryWhite,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    4.ph,
                    if (artist.genre.isNotEmpty)
                      Text(
                        artist.genre,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.listenerYellow,
                          fontFamily: 'Roboto',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          14.ph,
          Row(
            children: [
              Icon(
                Icons.people_outline_rounded,
                color: AppColors.huegrey,
                size: 18.sp,
              ),
              6.pw,
              Text(
                '${artist.followersCount} followers',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.snowWhite,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
          if (artist.bio.isNotEmpty) ...[
            12.ph,
            Text(
              artist.bio,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.coolGray,
                fontFamily: 'Roboto',
                height: 1.5,
              ),
            ),
          ],
          20.ph,
          Row(
            children: [
              Expanded(
                child: PrimaryElevatedButton(
                  onTap: onFollow,
                  text: isFollowing ? 'Following' : 'Follow',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isFollowing ? AppColors.primaryWhite : AppColors.primaryblack,
                    fontFamily: 'Roboto',
                  ),
                  buttonStyle: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? AppColors.listenerChipBg : AppColors.listenerYellow,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      side: isFollowing
                          ? BorderSide(
                              color: AppColors.primaryWhite.withValues(alpha: 0.10),
                              width: 1,
                            )
                          : BorderSide.none,
                    ),
                  ),
                ),
              ),
              if (onOptionsTap != null) ...[
                10.pw,
                GestureDetector(
                  onTap: onOptionsTap,
                  child: Container(
                    height: 48.h,
                    width: 48.h,
                    decoration: BoxDecoration(
                      color: AppColors.listenerChipBg,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: AppColors.primaryWhite.withValues(alpha: 0.10),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.more_vert,
                      color: AppColors.primaryWhite,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (performances.isNotEmpty && onPerformancesTap != null) ...[
            12.ph,
            PrimaryElevatedButton(
              onTap: onPerformancesTap!,
              text: 'View Performances (${performances.length})',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryWhite,
                fontFamily: 'Roboto',
              ),
              buttonStyle: ElevatedButton.styleFrom(
                backgroundColor: AppColors.listenerActiveTab,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ArtistAvatar extends StatelessWidget {
  const _ArtistAvatar({required this.artist});

  final ArtistDto artist;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.listenerAvatarBg,
        border: Border.all(
          color: AppColors.listenerYellow.withValues(alpha: 0.3),
          width: 2.w,
        ),
      ),
      child: NetworkSnap(
        imageUrl: artist.avatarUrl,
        width: 80.w,
        height: 80.w,
        fit: BoxFit.cover,
        borderRadiusGeometry: BorderRadius.circular(40.w),
        errorWidget: (_, __, ___) => _AvatarFallback(),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.person_rounded, color: AppColors.huegrey, size: 32.sp);
  }
}
