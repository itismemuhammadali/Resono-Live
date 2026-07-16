import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/artist_profile_controller.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.controller});

  final ArtistProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryWhite.withValues(alpha: 0.10),
          width: 1.09,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                _Avatar(
                  name: controller.artistName,
                  imageUrl: controller.artistImageUrl,
                ),
                16.pw,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.artistName,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryWhite,
                      ),
                    ),
                    6.ph,
                    Text(
                      controller.artistEmail,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.huegrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    value: controller.tracksCount.toString(),
                    label: 'Tracks',
                  ),
                ),
                8.pw,
                Expanded(
                  child: _StatItem(
                    value: controller.responsesCount.toString(),
                    label: 'Responses',
                  ),
                ),
                8.pw,
                Expanded(
                  child: _StatItem(
                    value: controller.savesCount.toString(),
                    label: 'Saves',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.imageUrl});

  final String name;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return SizedBox(
      width: 80.w,
      height: 80.w,
      child: ClipOval(child: _buildContent(initials)),
    );
  }

  Widget _buildContent(String initials) {
    final size = 80.w;
    final initialsWidget = Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.listenerActiveTab,
        ),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return imageUrl == null
          ? NetworkSnap(imageUrl: null, width: size, height: size)
          : initialsWidget;
    }

    return NetworkSnap(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadiusGeometry: BorderRadius.circular(size / 2),
      errorWidget: (ctx, url, err) => initialsWidget,
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.artistStatItemBg,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.listenerActiveTab,
            ),
          ),
          4.ph,
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryWhite,
            ),
          ),
        ],
      ),
    );
  }
}
