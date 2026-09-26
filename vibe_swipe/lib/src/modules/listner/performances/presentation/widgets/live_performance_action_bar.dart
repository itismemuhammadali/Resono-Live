import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class LivePerformanceActionBar extends StatelessWidget {
  const LivePerformanceActionBar({
    super.key,
    required this.isLiked,
    required this.isSaved,
    required this.isFollowing,
    required this.onLike,
    required this.onSave,
    required this.onFollow,
    required this.onTip,
  });

  final bool isLiked;
  final bool isSaved;
  final bool isFollowing;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onFollow;
  final VoidCallback onTip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: _OutlinedActionBtn(
              icon: isLiked
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              label: 'Like',
              iconColor: isLiked
                  ? AppColors.listenerDislikeRed
                  : AppColors.primaryWhite,
              labelColor: AppColors.primaryWhite,
              onTap: onLike,
            ),
          ),
          12.pw,
          Expanded(
            child: _OutlinedActionBtn(
              icon: isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              label: 'Save',
              iconColor: isSaved
                  ? AppColors.listenerActiveTab
                  : AppColors.primaryWhite,
              labelColor: AppColors.primaryWhite,
              onTap: onSave,
            ),
          ),
          12.pw,
          Expanded(
            child: _SolidActionBtn(
              icon: Icons.attach_money_rounded,
              label: 'Tip',
              bgColor: AppColors.listenerYellow,
              iconColor: AppColors.primaryblack,
              labelColor: AppColors.primaryblack,
              onTap: onTip,
            ),
          ),
          12.pw,
          Expanded(
            child: _SolidActionBtn(
              icon: isFollowing
                  ? Icons.check_rounded
                  : Icons.person_add_outlined,
              label: isFollowing ? 'Following' : 'Follow',
              bgColor: AppColors.listenerActiveTab,
              iconColor: AppColors.primaryblack,
              labelColor: AppColors.primaryblack,
              onTap: onFollow,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedActionBtn extends StatelessWidget {
  const _OutlinedActionBtn({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.labelColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color labelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFF121821),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFF1F2937),
            width: 1.09,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24.sp),
            6.ph,
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SolidActionBtn extends StatelessWidget {
  const _SolidActionBtn({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    required this.labelColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final Color labelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 22.sp),
            8.pw,
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
