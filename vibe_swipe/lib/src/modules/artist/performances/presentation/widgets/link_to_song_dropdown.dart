import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/artist_performances_controller.dart';

class LinkToSongDropdown extends StatelessWidget {
  const LinkToSongDropdown({
    super.key,
    required this.controller,
    required this.ref,
  });

  final ArtistPerformancesController controller;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSongPicker(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.listenerChipBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
            width: 1.09,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                controller.uploadLinkedSong ?? 'No Linked song',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: controller.uploadLinkedSong != null
                      ? AppColors.primaryWhite
                      : AppColors.huegrey,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.huegrey,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showSongPicker(BuildContext context) {
    final songs = controller.availableSongs;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.listenerChipBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Text(
                  'Link to Song',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: AppColors.primaryWhite,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _SongOption(
                label: 'No Linked song',
                isSelected: controller.uploadLinkedSong == null,
                onTap: () {
                  ref
                      .read(artistPerformancesControllerProvider)
                      .selectUploadLinkedSong(null);
                  Navigator.pop(context);
                },
              ),
              ...songs.map(
                (song) => _SongOption(
                  label: song,
                  isSelected: controller.uploadLinkedSong == song,
                  onTap: () {
                    ref
                        .read(artistPerformancesControllerProvider)
                        .selectUploadLinkedSong(song);
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }
}

class _SongOption extends StatelessWidget {
  const _SongOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: isSelected
                      ? AppColors.listenerActiveTab
                      : AppColors.primaryWhite,
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: AppColors.listenerActiveTab,
                size: 18.sp,
              ),
          ],
        ),
      ),
    );
  }
}
