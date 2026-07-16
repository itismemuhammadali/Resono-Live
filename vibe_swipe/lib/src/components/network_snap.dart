import 'package:vibe_swipe/src/components/shimmer_box.dart';

import '../core/utils/app_exports.dart';

class NetworkSnap extends StatelessWidget {
  final double? height, width, radius;
  final String? imageUrl;
  final String? imagePlaceHolder;
  final BoxFit? fit;
  final Color? color;
  final BorderRadiusGeometry? borderRadiusGeometry;
  final Widget Function(BuildContext, String, Object)? errorWidget;

  const NetworkSnap({
    super.key,
    this.fit,
    this.width,
    this.height,
    this.radius,
    this.imageUrl,
    this.color,
    this.imagePlaceHolder,
    this.errorWidget,
    this.borderRadiusGeometry,
  });

  @override
  Widget build(BuildContext context) {
    final double h = height ?? 34.sp;
    final double w = width ?? 34.sp;
    final BorderRadiusGeometry br =
        borderRadiusGeometry ?? BorderRadius.circular(radius ?? 10.r);

    // If imageUrl is null or empty, show errorWidget fallback or logo
    if (imageUrl == null || imageUrl!.isEmpty) {
      return ClipRRect(
        borderRadius: br,
        child: errorWidget != null
            ? errorWidget!(context, imageUrl ?? '', Exception('No image'))
            : _buildLogo(h, w),
      );
    }

    // On web, use Image.network to avoid CORS issues with CachedNetworkImage
    if (kIsWeb) {
      return ClipRRect(
        borderRadius: br,
        child: Image.network(
          imageUrl!,
          height: h,
          width: w,
          color: color,
          fit: fit ?? BoxFit.cover,
          errorBuilder: errorWidget != null
              ? (context, error, stackTrace) => errorWidget!(context, imageUrl!, error)
              : (context, error, stackTrace) => _buildLogo(h, w),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return ShimmerBox(height: h, width: w);
          },
        ),
      );
    }

    // On mobile, use CachedNetworkImage for caching benefits
    return ClipRRect(
      borderRadius: br,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        height: h,
        width: w,
        color: color,
        fit: fit ?? BoxFit.cover,
        placeholder: (context, url) => ShimmerBox(height: h, width: w),
        errorWidget: errorWidget ?? (context, url, error) => _buildLogo(h, w),
        fadeInDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  Widget _buildLogo(double h, double w) {
    return Container(
      height: h,
      width: w,
      padding: AppInsets.all(16.0),
      child: Image.asset(
        imagePlaceHolder ?? 'assets/logo/vibe_swip_logo.jpeg',
        fit: BoxFit.contain,
        color: AppColors.casper,
      ),
    );
  }
}
