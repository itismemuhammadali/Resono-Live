import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/artist_performances_controller.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key, required this.controller, required this.ref});

  final ArtistPerformancesController controller;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final categories = ArtistPerformancesController.availableCategories;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        mainAxisExtent: 50.h,
      ),
      itemCount: categories.length,
      itemBuilder: (_, i) {
        final category = categories[i];
        final isSelected = controller.selectedCategory == category;
        return GestureDetector(
          onTap: () => ref
              .read(artistPerformancesControllerProvider)
              .selectCategory(category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.listenerActiveTab.withValues(alpha: 0.15)
                  : const Color(0xFF121821),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.listenerActiveTab
                    : Colors.white.withValues(alpha: 0.10),
                width: 1.09,
              ),
            ),
            child: Text(
              category,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto',
                color: isSelected
                    ? AppColors.listenerActiveTab
                    : AppColors.primaryWhite,
                fontSize: 16.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}
