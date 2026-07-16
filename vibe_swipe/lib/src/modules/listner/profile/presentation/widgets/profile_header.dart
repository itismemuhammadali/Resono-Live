import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.username,
    this.profileImageUrl,
  });

  final String name;
  final String username;
  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 96.w,
            height: 96.w,
            child: Stack(
              children: [
                Container(
                  width: 96.w,
                  height: 96.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.listenerActiveTab,
                      width: 1.09.w,
                    ),
                  ),
                    child: ClipOval(
                    child: profileImageUrl != null && profileImageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: profileImageUrl!,
                            width: 96.w,
                            height: 96.w,
                            fit: BoxFit.cover,
                            cacheKey: profileImageUrl,
                            memCacheWidth: 192,
                            placeholder: (_, __) => Container(
                              width: 96.w,
                              height: 96.w,
                              color: AppColors.listenerChipBg,
                              child: Icon(
                                Icons.person,
                                color: AppColors.gray500,
                                size: 40.sp,
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 96.w,
                              height: 96.w,
                              color: AppColors.listenerChipBg,
                              child: Icon(
                                Icons.person,
                                color: AppColors.gray500,
                                size: 40.sp,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.listenerChipBg,
                            child: Icon(
                              Icons.person,
                              color: AppColors.gray500,
                              size: 40.sp,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 64.h,
                  left: 64.w,
                  child: const _EditBadge(),
                ),
              ],
            ),
          ),
          16.ph,
          Text(
            name.isNotEmpty ? name : 'Music Lover',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryWhite,
              fontFamily: 'Roboto',
            ),
          ),
          6.ph,
          Text(
            username.isNotEmpty ? '@$username' : '@musiclover',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.huegrey,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}

class _EditBadge extends StatelessWidget {
  const _EditBadge();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRouterGo.push(listenerEditProfileView),
      child: Container(
      width: 32.w,
      height: 32.w,
      padding: EdgeInsets.all(8.w),
      decoration: const BoxDecoration(
        color: AppColors.listenerActiveTab,
        shape: BoxShape.circle,
      ),
      child: FittedBox(
        child: Image.asset('assets/icons/png/profile_edit_icn.png'),
      ),
    ),
    );
  }
}
