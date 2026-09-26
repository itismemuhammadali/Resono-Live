import 'package:vibe_swipe/src/core/services/in_app_purchase_service.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/in_app_alert.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/modules/artist/earnings/presentation/widgets/payout_required_dialog.dart';
import 'package:vibe_swipe/src/modules/artist/register/presentation/widgets/artist_labeled_field.dart';
import '../../domain/entities/performance_entity.dart';
import '../controllers/artist_performances_controller.dart';
import '../widgets/category_grid.dart';
import '../widgets/edit_app_bar.dart';
import '../widgets/edit_cover_image_box.dart';
import '../widgets/edit_section_label.dart';
import '../widgets/edit_tag_chip_list.dart';
import '../widgets/tag_input_row.dart';

class EditPerformanceView extends ConsumerStatefulWidget {
  const EditPerformanceView({super.key, this.item});

  final PerformanceEntity? item;

  @override
  ConsumerState<EditPerformanceView> createState() =>
      _EditPerformanceViewState();
}

class _EditPerformanceViewState extends ConsumerState<EditPerformanceView> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.item != null) {
        final item = widget.item!;
        final dateStr =
            '${item.date.month.toString().padLeft(2, '0')}/${item.date.day.toString().padLeft(2, '0')}/${item.date.year}';
        final hour = item.date.hour == 0
            ? 12
            : (item.date.hour > 12 ? item.date.hour - 12 : item.date.hour);
        final period = item.date.hour < 12 ? 'AM' : 'PM';
        final timeStr =
            '${hour.toString().padLeft(2, '0')}:${item.date.minute.toString().padLeft(2, '0')} $period';
        final tier = item.ticketTier != null
            ? TicketTier.fromTierNumber(item.ticketTier)
            : TicketTier.fromPrice(item.ticketPrice);

        ref.read(artistPerformancesControllerProvider).initEditData(
              title: item.title,
              description: item.description ?? '',
              date: dateStr,
              time: timeStr,
              category: item.category,
              tags: [],
              coverImageUrl: item.thumbnailUrl,
              isPaid: item.isPaid,
              tier: tier,
            );
      } else {
        ref.read(artistPerformancesControllerProvider).initEditData(
              title: 'Acoustic Live Session',
              description:
                  'Join me for an intimate acoustic performance of my new songs',
              date: '05/18/2026',
              time: '12:00 AM',
              category: 'Acoustic',
              tags: ['acoustic', 'live', 'new music'],
              coverImageUrl: 'https://picsum.photos/seed/edit/400/220',
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EditAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const EditSectionLabel('Cover Image'),
                      12.ph,
                      EditCoverImageBox(
                        image: controller.coverImage,
                        imageBytes: controller.coverImageBytes,
                        previewUrl: controller.editCoverImageUrl,
                        onTap: () => ref
                            .read(artistPerformancesControllerProvider)
                            .pickCoverImage(context),
                      ),
                      24.ph,
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
                        maxLines: 4,
                        minLines: 4,
                        textInputType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        isLast: true,
                        onChanged: (_) => ref
                            .read(artistPerformancesControllerProvider)
                            .onSessionFieldChanged(),
                      ),
                      20.ph,
                      ArtistLabeledField(
                        label: 'Date',
                        hintText: 'MM/DD/YYYY',
                        controller: controller.dateController,
                        readOnly: true,
                        prefixWidget: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.gray500,
                            size: 18.sp,
                          ),
                        ),
                        onTap: () => ref
                            .read(artistPerformancesControllerProvider)
                            .pickDate(context),
                      ),
                      20.ph,
                      ArtistLabeledField(
                        label: 'Time',
                        hintText: '--:--',
                        controller: controller.timeController,
                        readOnly: true,
                        isLast: true,
                        prefixWidget: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Icon(
                            Icons.access_time,
                            color: AppColors.gray500,
                            size: 18.sp,
                          ),
                        ),
                        onTap: () => ref
                            .read(artistPerformancesControllerProvider)
                            .pickTime(context),
                      ),
                      20.ph,
                      const EditSectionLabel('Category'),
                      12.ph,
                      CategoryGrid(controller: controller, ref: ref),
                      20.ph,
                      const EditSectionLabel('Tags'),
                      12.ph,
                      TagInputRow(controller: controller, ref: ref),
                      if (controller.tags.isNotEmpty) ...[
                        12.ph,
                        EditTagChipList(controller: controller, ref: ref),
                      ],
                      24.ph,
                      const EditSectionLabel('Performance Access'),
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
                        onTap: _isSaving
                            ? () {}
                            : () async {
                                if (widget.item != null) {
                                  setState(() => _isSaving = true);
                                  final success = await ref
                                      .read(artistPerformancesControllerProvider.notifier)
                                      .updatePerformanceDetails(widget.item!.id);
                                  setState(() => _isSaving = false);
                                  if (context.mounted) {
                                    if (success) {
                                      InAppAlert.show(
                                        context,
                                        message: 'Performance updated successfully',
                                        isSuccess: true,
                                      );
                                      AppRouterGo.back();
                                    } else {
                                      InAppAlert.show(
                                        context,
                                        message: 'Failed to update performance',
                                        isSuccess: false,
                                      );
                                    }
                                  }
                                } else {
                                  AppRouterGo.back();
                                }
                              },
                        text: _isSaving ? 'Saving...' : 'Save Changes',
                        radius: 14,
                        leadingWidget: Image.asset(
                          'assets/icons/png/artist_edit_performance_save_icn.png',
                          width: 20.w,
                          height: 20.w,
                        ),
                        buttonStyle: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: 14.circular,
                          ),
                          backgroundColor: AppColors.listenerActiveTab,
                        ),
                      ),
                      20.ph,
                    ],
                  ),
                ),
              ),
            ],
          ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.listenerYellow.withValues(alpha: 0.15)
              : const Color(0xFF161C26),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.listenerYellow
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Roboto',
              color: isSelected ? AppColors.listenerYellow : AppColors.gray400,
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
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
                      color: AppColors.gray400,
                      fontSize: 9.sp,
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
