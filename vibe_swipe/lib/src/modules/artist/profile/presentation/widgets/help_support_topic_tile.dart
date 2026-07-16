import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/modules/artist/profile/domain/entities/topic_entity.dart';

class HelpSupportTopicTile extends StatelessWidget {
  const HelpSupportTopicTile({super.key, required this.topic});

  final TopicEntity topic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryWhite.withValues(alpha: 0.10),
          width: 1.09,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: AppColors.listenerYellow.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/icons/png/profile_help_support_tab_icn.png',
            ),
          ),
          16.pw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryWhite,
                  ),
                ),
                4.ph,
                Text(
                  topic.subtitle,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.huegrey,
                  ),
                ),
              ],
            ),
          ),
          16.pw,
          Image.asset('assets/icons/png/history_open_icn.png'),
        ],
      ),
    );
  }
}
