import '../core/utils/app_exports.dart';

class ShimmerBox extends StatelessWidget {
  final bool? showIcon;
  final double? height, width, borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.showIcon,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 34.sp,
      height: height ?? 34.sp,
      child: Shimmer.fromColors(
        // baseColor: Colors.grey,
        highlightColor: AppColors.shimmerHighlight,
        baseColor: AppColors.shimmerBase,
        //highlightColor: const Color(0xFFF4F4F4),
        direction: ShimmerDirection.ltr,
        child: Container(
          alignment: Alignment.bottomLeft,
          decoration: BoxDecoration(
            color: AppColors.shimmerContainer,
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
          ),
          child: showIcon == true
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset("assets/logo-icon.svg"),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
