class PostCardEntity {
  const PostCardEntity({
    required this.name,
    required this.caption,
    required this.song,
    required this.likes,
    required this.imageUrl,
    this.artistId = '',
    this.artistImageUrl = '',
    this.performanceId = '',
    this.title = '',
    this.status = 'upcoming',
    this.videoUrl = '',
    this.type = 'live',
  });

  final String name;
  final String caption;
  final String song;
  final String likes;
  final String imageUrl;
  final String artistId;
  final String artistImageUrl;
  final String performanceId;
  final String title;
  final String status;
  final String videoUrl;
  final String type;
}
