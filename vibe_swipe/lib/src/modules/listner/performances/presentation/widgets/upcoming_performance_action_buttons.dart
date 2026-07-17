import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class UpcomingPerformanceActionButtons extends StatelessWidget {
  const UpcomingPerformanceActionButtons({
    super.key,
    required this.isLiked,
    required this.isSaved,
    required this.likesCount,
    required this.onLike,
    required this.onSave,
    required this.onShare,
  });

  final bool isLiked;
  final bool isSaved;
  final int likesCount;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionBtn(
            icon: isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: likesCount > 0 ? '$likesCount Likes' : 'Like',
            color: isLiked ? AppColors.listenerLiveRed : AppColors.primaryWhite,
            onTap: onLike,
          ),
        ),
        12.pw,
        Expanded(
          child: _ActionBtn(
            icon: isSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            label: 'Save',
            color: isSaved
                ? AppColors.listenerActiveTab
                : AppColors.primaryWhite,
            onTap: onSave,
          ),
        ),
        12.pw,
        Expanded(
          child: _ActionBtn(
            icon: Icons.share_outlined,
            label: 'Share',
            color: AppColors.primaryWhite,
            onTap: onShare,
          ),
        ),
      ],
    );
  }
}


// ─── Action Button ────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: const Color(0xFF121821),
          borderRadius: BorderRadius.circular(16.r),
          border: Border(
            top: BorderSide(color: const Color(0xFF1F2937), width: 1.09.w),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20.sp),
            16.pw,
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
