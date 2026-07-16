import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/artist_performances_controller.dart';

class TagChipList extends StatelessWidget {
  const TagChipList({super.key, required this.controller, required this.ref});

  final ArtistPerformancesController controller;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: controller.tags.map((tag) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.listenerActiveTab.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColors.listenerActiveTab.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tag,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.listenerActiveTab,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              6.pw,
              GestureDetector(
                onTap: () => ref
                    .read(artistPerformancesControllerProvider)
                    .removeTag(tag),
                child: Icon(
                  Icons.close,
                  size: 14.sp,
                  color: AppColors.listenerActiveTab,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
