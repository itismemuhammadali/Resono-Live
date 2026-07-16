import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/modules/authentication/presentation/widgets/auth_back_button.dart';
import '../../domain/entities/community_topic_entity.dart';

class ArtistTopicDetailHeader extends StatelessWidget {
  const ArtistTopicDetailHeader({
    super.key,
    required this.topic,
    required this.activeCount,
  });

  final CommunityTopicEntity topic;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: 16.h,
      ),
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(color: AppColors.listenerChipBg, width: 1),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthBackButton(),
          12.ph,
          Text(
            topic.title,
            style: TextStyle(
              fontFamily: 'Roboto',
              color: AppColors.primaryWhite,
              fontSize: 24.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          4.ph,
          Text(
            '$activeCount active discussions',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.huegrey,
            ),
          ),
        ],
      ),
    );
  }
}
