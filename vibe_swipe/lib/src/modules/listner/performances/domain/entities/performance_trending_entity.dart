class PerformanceTrendingEntity {
  const PerformanceTrendingEntity({
    this.id = '',
    required this.title,
    required this.artist,
    this.artistId = '',
    required this.views,
    required this.thumbnailUrl,
  });

  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String views;
  final String thumbnailUrl;
}
