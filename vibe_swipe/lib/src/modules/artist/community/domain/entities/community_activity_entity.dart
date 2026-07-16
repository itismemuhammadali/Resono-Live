class CommunityActivityEntity {
  const CommunityActivityEntity({
    required this.actor,
    required this.action,
    required this.timeAgo,
    required this.asset,
  });

  final String actor;
  final String action;
  final String timeAgo;
  final String? asset;
}
