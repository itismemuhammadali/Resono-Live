import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/artist_performances_controller.dart';

class EditTagChipList extends StatelessWidget {
  const EditTagChipList({
    super.key,
    required this.controller,
    required this.ref,
  });

  final ArtistPerformancesController controller;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: controller.tags.map((tag) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2530),
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tag,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.primaryWhite,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              6.pw,
              GestureDetector(
                onTap: () => ref
                    .read(artistPerformancesControllerProvider)
                    .removeTag(tag),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(6.r),
                  child: Text(
                    '×',
                    style: TextStyle(
                      color: AppColors.primaryWhite,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
