import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class ImageSourceSheet extends StatelessWidget {
  const ImageSourceSheet({super.key, required this.onPicked});

  final void Function(XFile?) onPicked;

  static void show(BuildContext context, void Function(XFile?) onPicked) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ImageSourceSheet(onPicked: onPicked),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(
          top: BorderSide(
            color: AppColors.primaryWhite.withValues(alpha: 0.08),
            width: 1.w,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.primaryWhite.withValues(alpha: 0.2),
              borderRadius: 2.circular,
            ),
          ),
          20.ph,
          Text(
            'Select Image',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryWhite,
              fontFamily: 'Roboto',
            ),
          ),
          20.ph,
          _SourceTile(
            icon: Icons.camera_alt_outlined,
            label: 'Camera',
            onTap: () async {
              Navigator.pop(context);
              final file = await AppImagePicker.fromCamera();
              onPicked(file);
            },
          ),
          12.ph,
          _SourceTile(
            icon: Icons.photo_library_outlined,
            label: 'Choose from Gallery',
            onTap: () async {
              Navigator.pop(context);
              final file = await AppImagePicker.fromGallery();
              onPicked(file);
            },
          ),
          12.ph,
          _SourceTile(
            icon: Icons.close,
            label: 'Cancel',
            iconColor: const Color(0xFFEF4444),
            labelColor: const Color(0xFFEF4444),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.listenerBackButtonBorder.withValues(alpha: 0.3),
          borderRadius: 14.circular,
          border: Border.all(
            color: AppColors.primaryWhite.withValues(alpha: 0.06),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.listenerBackButtonBorder,
                borderRadius: 10.circular,
              ),
              child: FittedBox(
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.listenerActiveTab,
                ),
              ),
            ),
            14.pw,
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: labelColor ?? AppColors.primaryWhite,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
