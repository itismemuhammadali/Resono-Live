import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/faq_item.dart';

class FaqTile extends StatelessWidget {
  const FaqTile({super.key, required this.item});

  final FaqItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: 16.circular,
        border: Border.all(
          color: AppColors.primaryWhite.withValues(alpha: 0.06),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.question,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryWhite,
              fontFamily: 'Roboto',
            ),
          ),
          10.ph,
          Text(
            item.answer,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.huegrey,
              fontFamily: 'Roboto',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
