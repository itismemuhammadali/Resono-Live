import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/modules/artist/dashboard/presentation/controllers/artist_dashboard_controller.dart';

class QuickActionsSection extends ConsumerWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.read(artistDashboardControllerProvider);

    final actions = [
      _QuickAction(
        asset: 'assets/icons/png/artist_home_upload_icn.png',
        label: 'Upload Track',
        isHighlighted: true,
        onTap: () => dashboard.onTabTapped(1),
      ),
      _QuickAction(
        asset: 'assets/icons/png/artist_home_go_live_icn.png',
        label: 'Go Live',
        onTap: () => AppRouterGo.push(artistGoLiveSetupView),
      ),
      _QuickAction(
        asset: 'assets/icons/png/artist_home_createpost_icn.png',
        label: 'Create Post',
        onTap: () => AppRouterGo.push(artistCreatePostView),
      ),
      _QuickAction(
        asset: 'assets/icons/png/artist_home_analysis_icn.png',
        label: 'Analytics',
        onTap: () => dashboard.onTabTapped(3),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryWhite,
          ),
        ),
        12.ph,
        for (var i = 0; i < actions.length; i += 2) ...[
          Row(
            children: [
              Expanded(child: _ActionCard(action: actions[i])),
              if (i + 1 < actions.length) ...[
                12.pw,
                Expanded(child: _ActionCard(action: actions[i + 1])),
              ],
            ],
          ),
          if (i + 2 < actions.length) 8.ph,
        ],
      ],
    );
  }
}

class _QuickAction {
  final String asset;
  final String label;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.asset,
    required this.label,
    this.isHighlighted = false,
    this.onTap,
  });
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    final labelColor = action.isHighlighted
        ? AppColors.listenerChipBg
        : AppColors.primaryWhite;
    final iconColor = action.isHighlighted
        ? AppColors.listenerChipBg
        : AppColors.primaryWhite;

    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: action.isHighlighted
              ? AppColors.listenerActiveTab
              : AppColors.listenerChipBg,
          borderRadius: BorderRadius.circular(16.r),
          border: action.isHighlighted
              ? null
              : Border.all(
                  color: AppColors.primaryWhite.withValues(alpha: 0.10),
                  width: 1.09.w,
                ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(action.asset, width: 20.w, height: 20.w, color: iconColor),
              12.pw,
              Text(
                action.label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
