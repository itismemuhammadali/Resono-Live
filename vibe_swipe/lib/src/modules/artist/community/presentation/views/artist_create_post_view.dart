import 'package:vibe_swipe/src/components/custom_textfield.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controller/artist_community_controller.dart';
import '../widgets/artist_create_post_header.dart';
import '../widgets/artist_create_post_field_label.dart';
import '../widgets/artist_create_post_link_type_toggle.dart';
import '../widgets/artist_create_post_link_dropdown.dart';

class ArtistCreatePostView extends ConsumerWidget {
  const ArtistCreatePostView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(artistCommunityControllerProvider);

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
            children: [
              const ArtistCreatePostHeader(),
              Expanded(
                child: Form(
                  key: controller.formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        24.ph,
                        const ArtistCreatePostFieldLabel(text: 'Post Title'),
                        10.ph,
                        CustomTextField(
                          controller: controller.titleController,
                          hintText: "What's on your mind?",
                          fillColor: AppColors.listenerChipBg,
                          enableBorderColor: AppColors.primaryWhite.withValues(
                            alpha: 0.10,
                          ),
                          focusedBorderColor: AppColors.listenerYellow,
                          cursorColor: AppColors.listenerYellow,
                          fieldBorderRadius: 16,
                          borderWidth: 1.09,
                          textStyle: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primaryWhite,
                          ),
                          hintTextStyle: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.huegrey,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 18.h,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Post title is required';
                            }
                            return null;
                          },
                        ),
                        24.ph,
                        const ArtistCreatePostFieldLabel(text: 'Content'),
                        10.ph,
                        CustomTextField(
                          controller: controller.contentController,
                          hintText: 'Share your thoughts with your fans...',
                          maxLines: 6,
                          minLines: 6,
                          fillColor: AppColors.listenerChipBg,
                          enableBorderColor: AppColors.primaryWhite.withValues(
                            alpha: 0.10,
                          ),
                          focusedBorderColor: AppColors.listenerYellow,
                          cursorColor: AppColors.listenerYellow,
                          fieldBorderRadius: 16,
                          borderWidth: 1.09,
                          isLast: true,
                          textStyle: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primaryWhite,
                          ),
                          hintTextStyle: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.huegrey,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 20.h,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Content is required';
                            }
                            return null;
                          },
                        ),
                        24.ph,
                        const ArtistCreatePostFieldLabel(
                          text: 'Link Content (Optional)',
                          isRequired: false,
                        ),
                        12.ph,
                        ArtistCreatePostLinkTypeToggle(
                          controller: controller,
                          ref: ref,
                        ),
                        if (controller.linkType ==
                            ArtistPostLinkType.track) ...[
                          12.ph,
                          ArtistCreatePostLinkDropdown(
                            hint: 'Select a track',
                            items: ref.read(artistCommunityControllerProvider).availableTracks,
                            selected: controller.selectedTrack,
                            onSelect: (v) => ref
                                .read(artistCommunityControllerProvider)
                                .selectTrack(v),
                          ),
                        ],
                        if (controller.linkType ==
                            ArtistPostLinkType.performance) ...[
                          12.ph,
                          ArtistCreatePostLinkDropdown(
                            hint: 'Select a performance',
                            items:
                                ref.read(artistCommunityControllerProvider).availablePerformances,
                            selected: controller.selectedPerformance,
                            onSelect: (v) => ref
                                .read(artistCommunityControllerProvider)
                                .selectPerformance(v),
                          ),
                        ],
                        32.ph,
                        PrimaryElevatedButton(
                          onTap: controller.onPublishPost,
                          text: 'Publish Post',
                          enabled: controller.canPublish,
                          radius: 14,
                          disableButtonTextColor: AppColors.black,
                          buttonStyle: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: 14.circular,
                            ),
                            backgroundColor: AppColors.listenerActiveTab,
                            disabledBackgroundColor: AppColors.listenerActiveTab
                                .withValues(alpha: 0.25),
                          ),
                          leadingWidget: Image.asset(
                            'assets/icons/png/post_reply_btn_icn.png',
                          ),
                        ),
                        24.ph,
                      ],
                    ),
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
