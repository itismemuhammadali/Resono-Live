class PerformanceFeaturedEntity {
  const PerformanceFeaturedEntity({
    required this.title,
    required this.artist,
    required this.genre,
    required this.viewCount,
    required this.isLive,
    this.id = '',
    this.thumbnailUrl = '',
    this.videoUrl = '',
    this.artistId = '',
    this.artistImageUrl = '',
    this.description = '',
  });

  final String id;
  final String title;
  final String artist;
  final String genre;
  final String viewCount;
  final String description;
  final bool isLive;
  final String thumbnailUrl;
  final String videoUrl;
  final String artistId;
  final String artistImageUrl;
}
