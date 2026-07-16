import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/community_topic_entity.dart';

class ArtistCommunityTrendingTopicsSection extends StatelessWidget {
  const ArtistCommunityTrendingTopicsSection({super.key, required this.topics});

  final List<CommunityTopicEntity> topics;

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trending Topics',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryWhite,
          ),
        ),
        20.5.ph,
        if (topics.length >= 2)
          Row(
            children: [
              Expanded(child: _TopicCard(topic: topics[0])),
              12.pw,
              Expanded(child: _TopicCard(topic: topics[1])),
            ],
          ),
        if (topics.length >= 2) 12.ph,
        if (topics.length >= 4)
          Row(
            children: [
              Expanded(child: _TopicCard(topic: topics[2])),
              12.pw,
              Expanded(child: _TopicCard(topic: topics[3])),
            ],
          ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});

  final CommunityTopicEntity topic;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRouterGo.push(artistTopicDetailView, extra: topic),
      child: Container(
      padding: EdgeInsets.all(17.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.listenerYellow.withValues(alpha: 0.10),
            AppColors.listenerYellow.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border(
          top: BorderSide(
            color: AppColors.listenerYellow.withValues(alpha: 0.20),
            width: 1.09.w,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(topic.asset),
          6.ph,
          Text(
            topic.title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryWhite,
            ),
          ),
          6.ph,
          Row(
            children: [
              Expanded(
                child: Text(
                  topic.count,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.huegrey,
                  ),
                ),
              ),
              Text(
                topic.changePercent,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.emeraldGreen,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
