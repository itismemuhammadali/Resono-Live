import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/artist_performances_controller.dart';
import 'review_row.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.controller});

  final ArtistPerformancesController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1.09,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: controller.coverImageBytes != null
                  ? Image.memory(
                      controller.coverImageBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(
                      color: AppColors.listenerNavBorder,
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: AppColors.huegrey,
                          size: 48.sp,
                        ),
                      ),
                    ),
            ),
          ),
          10.ph,
          ReviewRow(
            label: 'Title',
            value: controller.titleController.text.trim().isEmpty
                ? '—'
                : controller.titleController.text.trim(),
          ),
          10.ph,
          ReviewRow(
            label: 'Genre',
            value: controller.selectedCategory ?? '—',
          ),
          10.ph,
          ReviewRow(
            label: 'Tags',
            value: controller.tags.isEmpty ? '—' : controller.tags.join(', '),
          ),
          10.ph,
          ReviewRow(
            label: 'Access',
            value: controller.isPaidPerformance
                ? 'Paid (\$${controller.selectedTier.price.toStringAsFixed(0)} - ${controller.selectedTier.passName})'
                : 'Free',
          ),
          10.ph,
          ReviewRow(
            label: 'Discoverable',
            value: controller.isDiscoverable ? 'Yes' : 'No',
          ),
        ],
      ),
    );
  }
}
