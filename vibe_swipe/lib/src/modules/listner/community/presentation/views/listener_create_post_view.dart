import 'package:vibe_swipe/src/components/custom_textfield.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/listener_create_post_controller.dart'
    show listenerCommunityControllerProvider, ListenerCommunityController;
import '../widgets/create_post_actions.dart';
import '../widgets/create_post_category_section.dart';
import '../widgets/create_post_field_label.dart';

class ListenerCreatePostView extends ConsumerWidget {
  const ListenerCreatePostView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(listenerCommunityControllerProvider);

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
              const ListenerPageHeader(title: 'Create Post'),
              Expanded(
                child: Form(
                  key: controller.formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        24.ph,
                        const CreatePostFieldLabel(text: 'Post Title'),
                        10.ph,
                        CustomTextField(
                          controller: controller.titleController,
                          hintText: 'Enter a descriptive title...',
                          maxLines: 3,
                          minLines: 3,
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
                            color: AppColors.primaryWhite,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 20.h,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Post title is required';
                            }
                            if (value.trim().length < 5) {
                              return 'Title must be at least 5 characters';
                            }
                            if (value.trim().length > 150) {
                              return 'Title must be under 150 characters';
                            }
                            return null;
                          },
                        ),
                        24.ph,
                        const CreatePostFieldLabel(text: 'Category'),
                        12.ph,
                        CreatePostCategorySection(
                          categories: ListenerCommunityController.postCategories,
                          selectedCategories: controller.selectedCategories,
                          onToggle: controller.toggleCategory,
                        ),
                        if (controller.categoryError) ...[
                          6.ph,
                          Padding(
                            padding: EdgeInsets.only(left: 4.w),
                            child: Text(
                              'Please select at least one category',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.eventRed,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ],
                        24.ph,
                        const CreatePostFieldLabel(text: 'Content'),
                        10.ph,
                        CustomTextField(
                          controller: controller.contentController,
                          hintText:
                              'Share your thoughts, ask questions, or start a discussion...',
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
                            color: AppColors.primaryWhite,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 20.h,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Post content is required';
                            }
                            if (value.trim().length < 10) {
                              return 'Content must be at least 10 characters';
                            }
                            return null;
                          },
                        ),
                        32.ph,
                      ],
                    ),
                  ),
                ),
              ),
              CreatePostActions(
                onPublish: controller.onPublish,
                onCancel: controller.onCancel,
                isPublishing: controller.isPublishing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
