import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class HomeActionButtons extends StatelessWidget {
  const HomeActionButtons({
    super.key,
    required this.onDislike,
    required this.onLike,
  });

  final VoidCallback onDislike;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleButton(
          onTap: onDislike,
          icon: Icons.close_rounded,
          iconColor: AppColors.listenerDislikeRed,
        ),
        32.pw,
        _CircleButton(
          onTap: onLike,
          icon: Icons.favorite_rounded,
          iconColor: AppColors.mintGreen,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.onTap,
    required this.icon,
    required this.iconColor,
  });

  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 74.w,
        height: 74.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF121821),
          border: Border.all(color: const Color(0xFF1F2937), width: 1.09),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              offset: const Offset(0, 4),
              blurRadius: 6,
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              offset: const Offset(0, 10),
              blurRadius: 15,
              spreadRadius: -3,
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 28.sp),
      ),
    );
  }
}
