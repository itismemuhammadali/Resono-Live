import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'dashed_border_painter.dart';

class CoverImageUploadBox extends StatelessWidget {
  const CoverImageUploadBox({
    super.key,
    required this.image,
    this.imageBytes,
    required this.onTap,
  });

  final XFile? image;
  final Uint8List? imageBytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 220.h,
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: AppColors.primaryWhite.withValues(alpha: 0.2),
            strokeWidth: 1.09,
            dashWidth: 2.17,
            dashSpace: 2,
            radius: 16.r,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: ColoredBox(
              color: AppColors.listenerChipBg,
              child: imageBytes != null
                  ? Image.memory(
                      imageBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/png/artist_upload_cover_icn.png',
                        ),
                        16.ph,
                        Text(
                          'Upload cover Image',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: AppColors.primaryWhite,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        8.ph,
                        Text(
                          'Square image, min 1000x1000px',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: AppColors.huegrey,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
