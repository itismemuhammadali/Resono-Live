class CommunityPostEntity {
  const CommunityPostEntity({
    this.id = '',
    required this.title,
    this.subtitle = '',
    this.content = '',
    this.category = '',
    this.authorId = '',
    this.authorName = '',
    this.authorRole = '',
    this.authorAvatarUrl = '',
    this.likes = 0,
    this.comments = 0,
    this.date = '',
    this.createdAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String category;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String authorAvatarUrl;
  final int likes;
  final int comments;
  final String date;
  final DateTime? createdAt;
}
