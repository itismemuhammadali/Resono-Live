import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/modules/artist/performances/domain/entities/performance_entity.dart';
import 'detail_row.dart';
import 'status_row.dart';

class SessionDetailsCard extends StatelessWidget {
  const SessionDetailsCard({super.key, required this.item});

  final PerformanceEntity item;

  String _formatDate(DateTime d) {
    final h = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
    final m = d.minute.toString().padLeft(2, '0');
    final s = d.second.toString().padLeft(2, '0');
    final period = d.hour < 12 ? 'AM' : 'PM';
    return '${d.month}/${d.day}/${d.year}, $h:$m:$s $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border(
          top: BorderSide(
            color: AppColors.primaryWhite.withValues(alpha: 0.10),
            width: 1.09,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Details',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryWhite,
            ),
          ),
          16.ph,
          DetailRow(label: 'Category', value: item.category ?? '—'),
          16.ph,
          DetailRow(label: 'Scheduled', value: _formatDate(item.date)),
          16.ph,
          StatusRow(status: item.status),
        ],
      ),
    );
  }
}
