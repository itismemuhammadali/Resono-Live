import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class PerformanceEntity {
  const PerformanceEntity({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.status,
    required this.date,
    required this.viewCount,
    required this.liveCount,
    this.description,
    this.category,
    this.commentCount = 0,
    this.newFansCount = 0,
    this.videoUrl = '',
    this.type = 'live',
  });

  final String id;
  final String title;
  final String thumbnailUrl;
  final PerformanceStatus status;
  final DateTime date;
  final int viewCount;
  final int liveCount;
  final String? description;
  final String? category;
  final int commentCount;
  final int newFansCount;
  final String videoUrl;
  final String type;

  bool get isRecorded => type == 'recorded';
  bool get isLive => type == 'live';
}
