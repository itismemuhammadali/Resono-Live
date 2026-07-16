import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
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
                        'Performance Type',
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
                              label: 'Paid',
                              isSelected: controller.isPaidPerformance,
                              onTap: () => ref
                                  .read(artistPerformancesControllerProvider.notifier)
                                  .setPerformanceType(true),
                            ),
                          ),
                        ],
                      ),
                      if (controller.isPaidPerformance) ...[
                        20.ph,
                        ArtistLabeledField(
                          label: 'Ticket Price (\$)',
                          hintText: 'e.g. 9.99',
                          controller: controller.priceController,
                          textInputType: const TextInputType.numberWithOptions(decimal: true),
                          isLast: true,
                          onChanged: (_) => ref
                              .read(artistPerformancesControllerProvider)
                              .onSessionFieldChanged(),
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
