import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'dashed_border_painter.dart';

class VideoUploadBox extends StatelessWidget {
  const VideoUploadBox({
    super.key,
    required this.videoFile,
    required this.onTap,
  });

  final XFile? videoFile;
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
              child: videoFile != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: AppColors.listenerActiveTab,
                          size: 48.r,
                        ),
                        12.ph,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Text(
                            videoFile!.name,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: AppColors.primaryWhite,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        8.ph,
                        Text(
                          'Tap to change',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: AppColors.huegrey,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/png/performance_unselected_icn.png',
                          width: 64.h,
                          height: 64.h,
                        ),
                        16.ph,
                        Text(
                          'Tap to upload video file',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: AppColors.primaryWhite,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        8.ph,
                        Text(
                          'MP4, MOV, or AVI',
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
