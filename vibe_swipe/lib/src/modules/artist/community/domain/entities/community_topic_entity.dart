class CommunityTopicEntity {
  const CommunityTopicEntity({
    required this.asset,
    required this.title,
    required this.count,
    required this.changePercent,
  });

  final String asset;
  final String title;
  final String count;
  final String changePercent;
}
