import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class CreatePostCategorySection extends StatelessWidget {
  const CreatePostCategorySection({
    super.key,
    required this.categories,
    required this.selectedCategories,
    required this.onToggle,
  });

  final List<String> categories;
  final Set<String> selectedCategories;
  final void Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: categories.map((category) {
        return GenreChip(
          label: category,
          isSelected: selectedCategories.contains(category),
          onTap: () => onToggle(category),
        );
      }).toList(),
    );
  }
}
