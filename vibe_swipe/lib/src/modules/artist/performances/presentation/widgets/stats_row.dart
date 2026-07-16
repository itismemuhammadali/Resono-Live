import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/modules/artist/performances/domain/entities/performance_entity.dart';
import 'stat_card.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key, required this.item});

  final PerformanceEntity item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.visibility_outlined,
            value: '${item.viewCount}',
            label: 'Viewers',
          ),
        ),
        12.pw,
        Expanded(
          child: StatCard(
            icon: Icons.chat_bubble_outline_rounded,
            value: '${item.commentCount}',
            label: 'Comments',
          ),
        ),
        12.pw,
        Expanded(
          child: StatCard(
            icon: Icons.people_outline_rounded,
            value: '${item.newFansCount}',
            label: 'New Fans',
          ),
        ),
      ],
    );
  }
}
