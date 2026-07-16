import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/community_topic_entity.dart';
import '../widgets/artist_topic_detail_header.dart';
import '../widgets/artist_topic_detail_discussion_tile.dart';

class ArtistTopicDetailView extends StatelessWidget {
  const ArtistTopicDetailView({super.key, required this.topic});

  final CommunityTopicEntity topic;

  @override
  Widget build(BuildContext context) {
    final discussions = <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/png/app_background_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ArtistTopicDetailHeader(
                topic: topic,
                activeCount: discussions.length,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    children: discussions.map((discussion) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: ArtistTopicDetailDiscussionTile(
                          discussion: discussion,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
