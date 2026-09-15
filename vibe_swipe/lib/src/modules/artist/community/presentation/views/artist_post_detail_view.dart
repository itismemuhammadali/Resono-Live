import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/community_post_entity.dart';
import '../widgets/artist_post_detail_header.dart';
import '../widgets/artist_post_detail_post_card.dart';
import '../widgets/artist_post_detail_comment_input.dart';

class ArtistPostDetailView extends StatefulWidget {
  const ArtistPostDetailView({super.key, required this.post});

  final CommunityPostEntity post;

  @override
  State<ArtistPostDetailView> createState() => _ArtistPostDetailViewState();
}

class _ArtistPostDetailViewState extends State<ArtistPostDetailView> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/png/app_background_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ArtistPostDetailHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      20.ph,
                      ArtistPostDetailPostCard(
                        post: widget.post,
                        onBlockComplete: () => Navigator.maybePop(context),
                      ),
                      24.ph,
                      Text(
                        'Comments (0)',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryWhite,
                        ),
                      ),
                      12.ph,
                      ArtistPostDetailCommentInput(
                        controller: _commentController,
                      ),
                      20.ph,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
