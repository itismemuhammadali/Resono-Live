import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'search_section_title.dart';

class SearchTrendingGenresSection extends StatelessWidget {
  const SearchTrendingGenresSection({
    super.key,
    required this.genres,
    this.selectedGenre = '',
    this.onGenreTap,
  });

  final List<String> genres;
  final String selectedGenre;
  final ValueChanged<String>? onGenreTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SearchSectionTitle(
          icon: Icons.trending_up_rounded,
          title: 'Trending Genres',
          iconColor: AppColors.listenerActiveTab,
        ),
        12.ph,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: genres.map((g) => _GenreChip(
            label: g,
            isSelected: g == selectedGenre,
            onTap: onGenreTap != null ? () => onGenreTap!(g) : null,
          )).toList(),
        ),
      ],
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label, this.isSelected = false, this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.listenerActiveTab : AppColors.listenerChipBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.listenerActiveTab : AppColors.listenerChipBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.primaryblack : AppColors.primaryWhite,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }
}
