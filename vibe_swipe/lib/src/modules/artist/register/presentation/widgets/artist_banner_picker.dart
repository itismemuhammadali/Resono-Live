import 'dart:typed_data';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class ArtistBannerPicker extends StatelessWidget {
  const ArtistBannerPicker({
    super.key,
    required this.onPicked,
    this.imageBytes,
  });

  final void Function(XFile?) onPicked;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Banner Image",
          style: TextStyle(
            fontFamily: 'Roboto',
            color: AppColors.gray300,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        12.ph,
        GestureDetector(
          onTap: () => ImageSourceSheet.show(context, onPicked),
          child: Container(
            width: double.infinity,
            height: 160.h,
            decoration: BoxDecoration(
              color: AppColors.listenerChipBg,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primaryWhite.withValues(alpha: 0.10),
                width: 1.09.w,
              ),
            ),
            child: imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.memory(
                      imageBytes!,
                      width: double.infinity,
                      height: 160.h,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.landscape_rounded,
                        color: AppColors.gray500,
                        size: 40.sp,
                      ),
                      12.ph,
                      Text(
                        'Upload banner image',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.primaryWhite,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      8.ph,
                      Text(
                        'Recommended: 1500x500px',
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
      ],
    );
  }
}
