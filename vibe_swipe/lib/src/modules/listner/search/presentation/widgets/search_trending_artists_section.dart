import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/search_artist_entity.dart';

class SearchTrendingArtistsSection extends StatelessWidget {
  const SearchTrendingArtistsSection({
    super.key,
    required this.artists,
    this.onArtistTap,
  });

  final List<SearchArtistEntity> artists;
  final void Function(String uid, String name)? onArtistTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trending Artists',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryWhite,
          ),
        ),
        12.ph,
        ...List.generate(
          artists.length,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _ArtistCard(
              uid: artists[i].uid,
              name: artists[i].name,
              genre: artists[i].genre,
              profileImageUrl: artists[i].profileImageUrl,
              onTap: onArtistTap != null
                  ? () => onArtistTap!(artists[i].uid, artists[i].name)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _ArtistCard extends StatelessWidget {
  const _ArtistCard({
    required this.uid,
    required this.name,
    required this.genre,
    this.profileImageUrl = '',
    this.onTap,
  });

  final String uid;
  final String name;
  final String genre;
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
              Image.asset("assets/icons/png/search_trending_icn.png"),
            14.pw,
            Column(
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
                3.ph,
                Text(
                  genre,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.santagrey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
