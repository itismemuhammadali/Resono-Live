import 'package:vibe_swipe/src/core/services/in_app_purchase_service.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/modules/artist/earnings/presentation/widgets/payout_required_dialog.dart';
import 'package:vibe_swipe/src/modules/artist/register/presentation/widgets/artist_labeled_field.dart';
import '../controllers/artist_performances_controller.dart';
import '../widgets/schedule_app_bar.dart';

class ScheduleLiveSessionView extends ConsumerWidget {
  const ScheduleLiveSessionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(artistPerformancesControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/png/app_background_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScheduleAppBar(
              currentStep: controller.currentStep,
              totalSteps: controller.totalSteps,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 24.h,
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Performance Details',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.primaryWhite,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      20.ph,
                      ArtistLabeledField(
                        label: 'Performance Title',
                        hintText: 'Enter performance title',
                        controller: controller.titleController,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) => ref
                            .read(artistPerformancesControllerProvider)
                            .onSessionFieldChanged(),
                      ),
                      20.ph,
                      ArtistLabeledField(
                        label: 'Description',
                        hintText: 'Enter performance description',
                        controller: controller.descriptionController,
                        maxLines: 6,
                        minLines: 5,
                        textInputType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        isLast: !controller.isPaidPerformance,
                        onChanged: (_) => ref
                            .read(artistPerformancesControllerProvider)
                            .onSessionFieldChanged(),
                      ),
                      24.ph,
                      Text(
                        'Performance Access',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.gray300,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      12.ph,
                      Row(
                        children: [
                          Expanded(
                            child: _PerformanceTypeChip(
                              label: 'Free',
                              isSelected: !controller.isPaidPerformance,
                              onTap: () => ref
                                  .read(artistPerformancesControllerProvider.notifier)
                                  .setPerformanceType(false),
                            ),
                          ),
                          12.pw,
                          Expanded(
                            child: _PerformanceTypeChip(
                              label: 'Paid (Ticket)',
                              isSelected: controller.isPaidPerformance,
                              onTap: () async {
                                final uid = locator<FirebaseAuthService>().getUid();
                                if (uid != null) {
                                  final userData = await locator<FirestoreService>().getUserData(uid);
                                  final isPayoutSetup = userData?['stripeOnboardingComplete'] == true;
                                  if (!isPayoutSetup && context.mounted) {
                                    PayoutRequiredDialog.show(context);
                                    return;
                                  }
                                }
                                ref
                                    .read(artistPerformancesControllerProvider.notifier)
                                    .setPerformanceType(true);
                              },
                            ),
                          ),
                        ],
                      ),
                      if (controller.isPaidPerformance) ...[
                        20.ph,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select Ticket Tier',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: AppColors.gray300,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Price: ${controller.selectedTier.formattedPrice}',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: AppColors.listenerYellow,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        12.ph,
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.w,
                            mainAxisSpacing: 10.h,
                            childAspectRatio: 2.1,
                          ),
                          itemCount: TicketTier.allTiers.length,
                          itemBuilder: (context, index) {
                            final tier = TicketTier.allTiers[index];
                            final isSelected =
                                controller.selectedTier.tierNumber == tier.tierNumber;
                            return _TicketTierTile(
                              tier: tier,
                              isSelected: isSelected,
                              onTap: () => ref
                                  .read(artistPerformancesControllerProvider.notifier)
                                  .selectTicketTier(tier),
                            );
                          },
                        ),
                      ],
                      32.ph,
                      PrimaryElevatedButton(
                        onTap: () => AppRouterGo.push(
                          artistScheduleCoverImageView,
                        ),
                        text: 'Continue',
                        enabled: controller.canContinueSession,
                        radius: 14,
                        buttonStyle: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: 14.circular,
                          ),
                          backgroundColor: AppColors.listenerActiveTab,
                          disabledBackgroundColor:
                              AppColors.listenerActiveTab.withValues(alpha: 0.25),
                        ),
                      ),
                      20.ph,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceTypeChip extends StatelessWidget {
  const _PerformanceTypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.listenerActiveTab
              : AppColors.listenerChipBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.listenerActiveTab
                : AppColors.listenerChipBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? AppColors.primaryblack
                  : AppColors.primaryWhite,
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketTierTile extends StatelessWidget {
  const _TicketTierTile({
    required this.tier,
    required this.isSelected,
    required this.onTap,
  });

  final TicketTier tier;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.listenerYellow.withValues(alpha: 0.12)
              : const Color(0xFF161C26),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.listenerYellow
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${tier.name}: ${tier.passName} • ${tier.formattedPrice}',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: isSelected ? AppColors.listenerYellow : AppColors.primaryWhite,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  2.ph,
                  Text(
                    tier.fullName,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: AppColors.santagrey,
                      fontSize: 10.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.listenerYellow,
                size: 16.sp,
              ),
          ],
        ),
      ),
    );
  }
}
