import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class ArtistCommunityAvatarCircle extends StatelessWidget {
  const ArtistCommunityAvatarCircle({
    super.key,
    required this.name,
    required this.size,
  });

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.listenerActiveTab.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: (size * 0.38).sp,
          fontWeight: FontWeight.w600,
          color: AppColors.listenerActiveTab,
        ),
      ),
    );
  }
}
