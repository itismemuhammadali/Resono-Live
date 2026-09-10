import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../data/dtos/artist_dto.dart';
import '../widgets/artist_hero_section.dart';
import '../widgets/artist_info_card.dart';
import '../widgets/artist_performances_sheet.dart';
import '../widgets/artist_top_songs_section.dart';
import 'package:vibe_swipe/src/modules/listner/home/presentation/widgets/sponsored_ad_widgets.dart';
import 'package:vibe_swipe/src/core/utils/report_block_helper.dart';
import 'package:vibe_swipe/src/modules/listner/home/presentation/controllers/listener_home_controller.dart';


class ArtistProfileView extends ConsumerStatefulWidget {
  const ArtistProfileView({super.key, required this.args});

  final ArtistProfileArgs args;

  @override
  ConsumerState<ArtistProfileView> createState() => _ArtistProfileViewState();
}

class _ArtistProfileViewState extends ConsumerState<ArtistProfileView> {
  ArtistDto? _artist;
  bool _isLoading = true;
  bool _isFollowing = false;
  List<Map<String, dynamic>> _performances = [];

  @override
  void initState() {
    super.initState();
    _fetchArtist();
    _fetchFollowState();
  }

  Future<void> _fetchArtist() async {
    try {
      final dataFuture = locator<FirestoreService>().getUserProfileById(widget.args.artistId);
      final performancesFuture = locator<FirestoreService>().getPerformances(
        artistId: widget.args.artistId,
        limit: 10,
      );

      final data = await dataFuture;
      final performances = await performancesFuture;

      if (data != null && mounted) {
        final genres = data['genres'] is List ? (data['genres'] as List).cast<String>() : <String>[];

        final coverUrlValue = data['coverUrl'] ?? data['profileCoverUrl'] ?? data['coverImage'];
        final avatarUrlValue = data['profileImageUrl'] ?? data['avatarUrl'] ?? data['profileImage'] ?? data['image'];

        setState(() {
          _performances = performances;
          _artist = ArtistDto(
            id: widget.args.artistId,
            name: (data['artistName'] ?? data['name'] ?? widget.args.artistName).toString(),
            genre: genres.isNotEmpty ? genres.first : '',
            followersCount: (data['followersCount'] ?? 0).toString(),
            bio: (data['bio'] ?? '').toString(),
            coverColors: const [Color(0xFF6B21A8), Color(0xFF1E1B4B)],
            coverUrl: (coverUrlValue != null && coverUrlValue.toString().isNotEmpty)
                ? coverUrlValue.toString()
                : null,
            avatarUrl: (avatarUrlValue != null && avatarUrlValue.toString().isNotEmpty)
                ? avatarUrlValue.toString()
                : null,
            topSongs: performances.map((p) {
              return ArtistTopSongDto(
                id: p['id'] ?? '',
                title: (p['title'] ?? p['name'] ?? 'Untitled').toString(),
                playsCount: '${p['playsCount'] ?? p['viewers_count'] ?? 0} plays',
                coverColors: const [Color(0xFF6B21A8), Color(0xFF1E1B4B)],
                coverUrl: (p['thumbnailUrl'] ?? '').toString().isNotEmpty
                    ? p['thumbnailUrl'].toString()
                    : null,
              );
            }).toList(),
          );
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _artist = ArtistDto(
            id: widget.args.artistId,
            name: widget.args.artistName,
            genre: '',
            followersCount: '0',
            bio: '',
            coverColors: const [Color(0xFF6B21A8), Color(0xFF1E1B4B)],
            topSongs: const [],
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      appPrint('[ArtistProfile] Error fetching artist: $e');
      if (mounted) {
        setState(() {
          _artist = ArtistDto(
            id: widget.args.artistId,
            name: widget.args.artistName,
            genre: '',
            followersCount: '0',
            bio: '',
            coverColors: const [Color(0xFF6B21A8), Color(0xFF1E1B4B)],
            topSongs: const [],
          );
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchFollowState() async {
    try {
      final data = await locator<FirestoreService>().getFollowState(artistId: widget.args.artistId);
      if (data != null && mounted) {
        final following = data['isFollowing'];
        setState(() {
          _isFollowing = following == true;
          final followersCount = data['followersCount'];
          if (followersCount != null && _artist != null) {
            _artist = ArtistDto(
              id: _artist!.id,
              name: _artist!.name,
              genre: _artist!.genre,
              followersCount: followersCount.toString(),
              bio: _artist!.bio,
              coverColors: _artist!.coverColors,
              topSongs: _artist!.topSongs,
              coverUrl: _artist!.coverUrl,
              avatarUrl: _artist!.avatarUrl,
            );
          }
        });
      }
    } catch (e) {
      appPrint('[ArtistProfile] Error fetching follow state: $e');
    }
  }

  Future<void> _toggleFollow() async {
    final previousFollowing = _isFollowing;
    final previousCount = int.tryParse(_artist?.followersCount ?? '0') ?? 0;

    setState(() {
      _isFollowing = !_isFollowing;
      _artist = ArtistDto(
        id: _artist!.id,
        name: _artist!.name,
        genre: _artist!.genre,
        followersCount: (previousFollowing ? previousCount - 1 : previousCount + 1).toString(),
        bio: _artist!.bio,
        coverColors: _artist!.coverColors,
        topSongs: _artist!.topSongs,
        coverUrl: _artist!.coverUrl,
        avatarUrl: _artist!.avatarUrl,
      );
    });

    try {
      final result = await locator<FirestoreService>().toggleFollow(artistId: widget.args.artistId);
      if (result != null && mounted) {
        final actualFollowing = result['followed'] ?? _isFollowing;
        if (actualFollowing != _isFollowing) {
          setState(() {
            _isFollowing = actualFollowing;
          });
        }
      }
    } catch (e) {
      appPrint('[ArtistProfile] Error toggling follow: $e');
      if (mounted) {
        setState(() {
          _isFollowing = previousFollowing;
          _artist = ArtistDto(
            id: _artist!.id,
            name: _artist!.name,
            genre: _artist!.genre,
            followersCount: previousCount.toString(),
            bio: _artist!.bio,
            coverColors: _artist!.coverColors,
            topSongs: _artist!.topSongs,
            coverUrl: _artist!.coverUrl,
            avatarUrl: _artist!.avatarUrl,
          );
        });
      }
    }
  }

  void _showPerformancesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ArtistPerformancesSheet(
        performances: _performances,
        artistName: _artist?.name ?? '',
        artistImageUrl: _artist?.avatarUrl ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.listenerActiveTab,
                strokeWidth: 2.5,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ArtistHeroSection(artist: _artist!),
                  Transform.translate(
                    offset: Offset(0, -60.h),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ArtistInfoCard(
                            artist: _artist!,
                            isFollowing: _isFollowing,
                            onFollow: _toggleFollow,
                            performances: _performances,
                            onPerformancesTap: () => _showPerformancesSheet(),
                            onOptionsTap: () {
                              ReportBlockHelper.showArtistOptionsModal(
                                context,
                                artistId: widget.args.artistId,
                                artistName: _artist?.name ?? widget.args.artistName,
                                onArtistBlocked: () {
                                  ref.read(listenerHomeControllerProvider).removeCardsForArtist(widget.args.artistId);
                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                              );
                            },
                          ),
                          28.ph,
                          ArtistTopSongsSection(songs: _artist!.topSongs),
                          24.ph,
                          const SponsoredAdBanner(placement: 'Artist Profile'),
                        ],
                      ),

                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
