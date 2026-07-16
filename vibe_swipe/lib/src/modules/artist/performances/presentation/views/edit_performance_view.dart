import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/modules/artist/register/presentation/widgets/artist_labeled_field.dart';
import '../controllers/artist_performances_controller.dart';
import '../widgets/category_grid.dart';
import '../widgets/edit_app_bar.dart';
import '../widgets/edit_cover_image_box.dart';
import '../widgets/edit_section_label.dart';
import '../widgets/edit_tag_chip_list.dart';
import '../widgets/tag_input_row.dart';

class EditPerformanceView extends ConsumerStatefulWidget {
  const EditPerformanceView({super.key});

  @override
  ConsumerState<EditPerformanceView> createState() =>
      _EditPerformanceViewState();
}

class _EditPerformanceViewState extends ConsumerState<EditPerformanceView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(artistPerformancesControllerProvider)
          .initEditData(
            title: 'Acoustic Live Session',
            description:
                'Join me for an intimate acoustic performance of my new songs',
            date: '05/18/2026',
            time: '12:00 AM',
            category: 'Acoustic',
            tags: ['acoustic', 'live', 'new music'],
            coverImageUrl: 'https://picsum.photos/seed/edit/400/220',
          );
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
                      32.ph,
                      PrimaryElevatedButton(
                        onTap: () => AppRouterGo.back(),
                        text: 'Save Changes',
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
