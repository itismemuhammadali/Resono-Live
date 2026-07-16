import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controller/artist_community_controller.dart';
import 'artist_create_post_toggle_btn.dart';

class ArtistCreatePostLinkTypeToggle extends StatelessWidget {
  const ArtistCreatePostLinkTypeToggle({
    super.key,
    required this.controller,
    required this.ref,
  });

  final ArtistCommunityController controller;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ArtistCreatePostToggleBtn(
          label: 'None',
          isSelected: controller.linkType == ArtistPostLinkType.none,
          onTap: () => ref
              .read(artistCommunityControllerProvider)
              .setLinkType(ArtistPostLinkType.none),
        ),
        8.pw,
        ArtistCreatePostToggleBtn(
          label: 'Track',
          asset: 'assets/icons/png/song_music_icn.png',
          isSelected: controller.linkType == ArtistPostLinkType.track,
          onTap: () => ref
              .read(artistCommunityControllerProvider)
              .setLinkType(ArtistPostLinkType.track),
        ),
        8.pw,
        ArtistCreatePostToggleBtn(
          label: 'Performance',
          asset: 'assets/icons/png/artist_home_go_live_icn.png',
          isSelected: controller.linkType == ArtistPostLinkType.performance,
          onTap: () => ref
              .read(artistCommunityControllerProvider)
              .setLinkType(ArtistPostLinkType.performance),
        ),
      ],
    );
  }
}
