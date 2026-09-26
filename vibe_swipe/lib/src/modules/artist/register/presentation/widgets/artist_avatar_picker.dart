import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class ArtistAvatarPicker extends StatelessWidget {
  const ArtistAvatarPicker({
    super.key,
    required this.onPicked,
    this.imageBytes,
  });

  final void Function(XFile?) onPicked;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => ImageSourceSheet.show(context, onPicked),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 128.w,
              height: 128.h,
              decoration: BoxDecoration(
                color: AppColors.listenerChipBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.listenerChipBorder,
                  width: 1.5,
                ),
              ),
              child: imageBytes != null
                  ? ClipOval(
                      child: Image.memory(
                        imageBytes!,
                        width: 128.w,
                        height: 128.h,
                        fit: BoxFit.cover,
                      ),
                    )
                  : (FirebaseAuth.instance.currentUser?.photoURL != null &&
                          FirebaseAuth.instance.currentUser!.photoURL!.isNotEmpty)
                      ? ClipOval(
                          child: Image.network(
                            FirebaseAuth.instance.currentUser!.photoURL!,
                            width: 128.w,
                            height: 128.h,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.gray500,
                              size: 48.sp,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.gray500,
                          size: 48.sp,
                        ),
            ),
            Positioned(
              bottom: 0,
              right: -4,
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: const BoxDecoration(
                  color: AppColors.listenerYellow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.upload_rounded,
                  color: AppColors.primaryblack,
                  size: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
