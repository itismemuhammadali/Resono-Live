class PerformanceUpcomingEntity {
  const PerformanceUpcomingEntity({
    required this.title,
    required this.artist,
    required this.genre,
    required this.time,
    required this.thumbnailUrl,
    required this.artistImageUrl,
    this.id = '',
    this.videoUrl = '',
    this.artistId = '',
    this.description = '',
    this.views = 0,
    this.type = 'live',
    this.scheduledAt,
  });

  final String id;
  final String title;
  final String artist;
  final String genre;
  final String time;
  final String thumbnailUrl;
  final String artistImageUrl;
  final String videoUrl;
  final String artistId;
  final String description;
  final int views;
  final String type;
  final DateTime? scheduledAt;

  bool get isRecorded => type == 'recorded';
  bool get isLive => type == 'live';
}
