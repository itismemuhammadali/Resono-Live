class CommunityDiscussionEntity {
  const CommunityDiscussionEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.authorId,
    required this.replies,
    required this.likes,
    required this.date,
    this.content = '',
  });

  final String id;
  final String title;
  final String author;
  final String authorId;
  final int replies;
  final int likes;
  final String date;
  final String content;
}
