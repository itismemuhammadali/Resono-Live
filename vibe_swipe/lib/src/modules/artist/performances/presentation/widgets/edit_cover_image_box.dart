import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class EditCoverImageBox extends StatelessWidget {
  const EditCoverImageBox({
    super.key,
    required this.image,
    this.imageBytes,
    required this.onTap,
    this.previewUrl,
  });

  final XFile? image;
  final Uint8List? imageBytes;
  final String? previewUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: SizedBox(
          width: double.infinity,
          height: 220.h,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageBytes != null)
                Image.memory(imageBytes!, fit: BoxFit.cover)
              else if (previewUrl != null)
                NetworkSnap(imageUrl: previewUrl, width: 1.sw, height: 220.h, fit: BoxFit.cover, radius: 0)
              else
                ColoredBox(color: AppColors.listenerChipBg),
              Positioned(
                bottom: 12.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.listenerDashboardBg.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        color: AppColors.primaryWhite,
                        size: 14.sp,
                      ),
                      4.pw,
                      Text(
                        'Change',
                        style: TextStyle(
                          color: AppColors.primaryWhite,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
