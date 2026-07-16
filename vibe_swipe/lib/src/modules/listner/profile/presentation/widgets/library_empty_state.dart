import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class LibraryEmptyState extends StatelessWidget {
  const LibraryEmptyState({super.key, required this.isHistory});

  final bool isHistory;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHistory
                ? Icons.history_rounded
                : Icons.bookmark_outline_rounded,
            color: AppColors.huegrey,
            size: 56.sp,
          ),
          16.ph,
          Text(
            isHistory ? 'No listening history yet' : 'No saved songs yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.huegrey,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}
