import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/in_app_alert.dart';
import '../../domain/entities/performance_entity.dart';
import '../controllers/artist_performances_controller.dart';
import 'delete_performance_modal.dart';

class PerformanceCard extends StatelessWidget {
  const PerformanceCard({super.key, required this.item});

  final PerformanceEntity item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.h),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: item.isRecorded
              ? const Color(0xFF4A90A4).withValues(alpha: 0.3)
              : AppColors.primaryWhite.withValues(alpha: 0.10),
          width: 1.09,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Thumbnail(url: item.thumbnailUrl, isRecorded: item.isRecorded),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.w, 0, 6.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _Title(title: item.title)),
                      _MenuButton(status: item.status, item: item),
                    ],
                  ),
                  // 7.ph,
                  _StatusBadge(status: item.status, type: item.type),
                  9.ph,
                  _DateRow(date: item.date),
                  6.ph,
                  _StatsRow(
                    viewCount: item.viewCount,
                    liveCount: item.liveCount,
                    isRecorded: item.isRecorded,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url, required this.isRecorded});
  final String url;
  final bool isRecorded;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NetworkSnap(
          imageUrl: url,
          width: 110.w,
          height: 110.h,
          fit: BoxFit.cover,
          radius: 10,
          errorWidget: (_, __, ___) => _placeholder(),
        ),
        if (isRecorded)
          Positioned(
            top: 6.h,
            left: 6.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90A4),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(
                Icons.videocam,
                color: AppColors.primaryWhite,
                size: 12.sp,
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width: 110.w,
      height: 110.h,
      color: AppColors.charcoalgrey,
      child: Icon(Icons.music_note, color: AppColors.huegrey, size: 28.sp),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryWhite,
        height: 1.3,
      ),
    );
  }
}

class _MenuButton extends ConsumerWidget {
  const _MenuButton({required this.status, required this.item});
  final PerformanceStatus status;
  final PerformanceEntity item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<PerformanceMenuAction>(
      onSelected: (action) {
        if (action == PerformanceMenuAction.edit) {
          AppRouterGo.push(artistEditPerformanceView, extra: item);
        } else if (action == PerformanceMenuAction.startLive) {
          AppRouterGo.push(artistLiveBroadcastView, extra: item);
        } else if (action == PerformanceMenuAction.delete) {
          DeletePerformanceModal.show(context, () async {
            final success = await ref
                .read(artistPerformancesControllerProvider.notifier)
                .deletePerformance(item.id);
            if (context.mounted) {
              if (success) {
                InAppAlert.show(
                  context,
                  message: 'Performance deleted successfully',
                  isSuccess: true,
                );
              } else {
                InAppAlert.show(
                  context,
                  message: 'Failed to delete performance',
                  isSuccess: false,
                );
              }
            }
          });
        }
      },
      color: AppColors.listenerPopupMenuBg,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      offset: Offset(0, 8.h),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: PerformanceMenuAction.edit,
          child: Row(
            children: [
              Image.asset(
                'assets/icons/png/profile_edit_profile_tab_icn.png',
                color: AppColors.primaryWhite,
                width: 16.w,
                height: 16.w,
              ),
              10.pw,
              Text(
                'Edit',
                style: TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (status == PerformanceStatus.upcoming && item.isLive)
          PopupMenuItem(
            value: PerformanceMenuAction.startLive,
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/png/artist_performance_start_live.png',
                  color: AppColors.primaryWhite,
                  width: 16.w,
                  height: 16.w,
                ),
                10.pw,
                Text(
                  'Start Live',
                  style: TextStyle(
                    color: AppColors.primaryWhite,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: PerformanceMenuAction.delete,
          child: Row(
            children: [
              Image.asset(
                'assets/icons/png/history_dlt_icn.png',
                width: 16.w,
                height: 16.w,
              ),
              10.pw,
              Text(
                'Delete',
                style: TextStyle(
                  color: AppColors.deleteRed,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: AppColors.primaryWhite.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.more_vert,
          color: AppColors.primaryWhite,
          size: 20.sp,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.type});
  final PerformanceStatus status;
  final String type;

  @override
  Widget build(BuildContext context) {
    final isRecorded = type == 'recorded';

    final (label, bgColor, textColor, hPad) = switch (status) {
      PerformanceStatus.upcoming => (
          isRecorded ? 'recorded' : 'upcoming',
          isRecorded
              ? const Color(0xFF4A90A4).withValues(alpha: 0.20)
              : AppColors.listenerActiveTab.withValues(alpha: 0.20),
          isRecorded ? const Color(0xFF4A90A4) : AppColors.listenerActiveTab,
          7.0,
        ),
      PerformanceStatus.past => (
          'past',
          AppColors.listenerPastBadgeBg,
          AppColors.huegrey,
          7.0,
        ),
      PerformanceStatus.live => (
          'live',
          Colors.red.withValues(alpha: 0.20),
          Colors.redAccent,
          8.0,
        ),
      PerformanceStatus.pending => (
          'pending',
          AppColors.listenerPendingBlue.withValues(alpha: 0.20),
          AppColors.listenerPendingBlue,
          8.0,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: textColor,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.date});
  final DateTime date;

  String _format(DateTime d) {
    final h = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
    final m = d.minute.toString().padLeft(2, '0');
    final period = d.hour < 12 ? 'AM' : 'PM';
    return '${d.month}/${d.day}/${d.year}, $h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          color: AppColors.huegrey,
          size: 16.sp,
        ),
        5.pw,
        Expanded(
          child: Text(
            _format(date),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.huegrey,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.viewCount, required this.liveCount, required this.isRecorded});
  final int viewCount;
  final int liveCount;
  final bool isRecorded;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.visibility_outlined, color: AppColors.huegrey, size: 16.sp),
        4.pw,
        Text(
          '$viewCount',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryWhite,
          ),
        ),
        12.pw,
        if (isRecorded) ...[
          Icon(Icons.videocam_outlined, color: AppColors.huegrey, size: 16.sp),
          4.pw,
          Text(
            'Recorded',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4A90A4),
            ),
          ),
        ] else ...[
          Image.asset(
            'assets/icons/png/artist_performance_live_icn.png',
            width: 16.w,
            height: 16.w,
            color: AppColors.huegrey,
            errorBuilder: (_, __, ___) => Icon(
              Icons.sensors_outlined,
              color: AppColors.huegrey,
              size: 16.sp,
            ),
          ),
          4.pw,
          Text(
            '$liveCount live',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryWhite,
            ),
          ),
        ],
      ],
    );
  }
}
