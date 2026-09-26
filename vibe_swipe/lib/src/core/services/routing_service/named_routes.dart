// ignore_for_file: strict_top_level_inference

// This is also known as declerative routing
import '../../utils/app_exports.dart';
import 'package:vibe_swipe/src/modules/authentication/presentation/views/mode_selection_view.dart';
import '../../../modules/authentication/presentation/views/onboarding_view.dart';
import '../../../modules/authentication/presentation/views/login_view.dart';
import '../../../modules/authentication/presentation/views/forgot_password_view.dart';
import '../../../modules/authentication/presentation/views/create_new_password_view.dart';
import '../../../modules/listner/register/presentation/views/listner_signup_view.dart';
import '../../../modules/listner/register/presentation/views/profile_setup_view.dart';
import '../../../modules/listner/register/presentation/views/favorite_genres_view.dart';
import '../../../modules/listner/register/presentation/views/disliked_genres_view.dart';
import '../../../modules/listner/dashboard/presentation/views/listener_dashboard_view.dart';
import '../../../modules/listner/profile/presentation/views/listener_edit_profile_view.dart';
import '../../../modules/listner/profile/presentation/views/listener_preferences_view.dart';
import '../../../modules/listner/profile/presentation/views/listener_notifications_view.dart';
import '../../../modules/listner/profile/presentation/views/notification_detail_view.dart';
import '../../../modules/listner/profile/presentation/views/listener_privacy_settings_view.dart';
import '../../../modules/listner/profile/presentation/views/listener_help_support_view.dart';
import '../../../modules/listner/profile/presentation/views/listener_library_view.dart';
import '../../../modules/listner/profile/presentation/views/library_song_detail_view.dart';
import '../../../modules/listner/profile/presentation/views/artist_profile_view.dart';
import '../../../modules/listner/profile/data/dtos/notification_dto.dart';
import '../../../modules/listner/profile/data/dtos/library_song_dto.dart';
import '../../../modules/listner/profile/data/dtos/artist_dto.dart';
import '../../../modules/listner/community/presentation/views/listener_create_post_view.dart';
import '../../../modules/listner/community/presentation/views/listener_genre_community_detail_view.dart';
import '../../../modules/listner/community/presentation/views/listener_discussion_detail_view.dart';
import '../../../modules/listner/performances/presentation/views/listener_live_performance_view.dart';
import '../../../modules/listner/performances/presentation/views/listener_upcoming_performance_detail_view.dart';
import '../../../modules/listner/performances/domain/entities/performance_featured_entity.dart';
import '../../../modules/listner/performances/domain/entities/performance_upcoming_entity.dart';
import '../../../modules/artist/register/presentation/views/artist_signup_view.dart';
import '../../../modules/artist/register/presentation/views/artist_setup_view.dart';
import '../../../modules/artist/dashboard/presentation/views/artist_dashboard_view.dart';
import '../../../modules/artist/performances/presentation/views/schedule_live_session_view.dart';
import '../../../modules/artist/performances/presentation/views/schedule_cover_image_view.dart';
import '../../../modules/artist/performances/presentation/views/schedule_date_time_view.dart';
import '../../../modules/artist/performances/presentation/views/schedule_category_tags_view.dart';
import '../../../modules/artist/performances/presentation/views/schedule_review_view.dart';
import '../../../modules/artist/performances/presentation/views/schedule_success_view.dart';
import '../../../modules/artist/performances/presentation/views/upload_video_view.dart';
import '../../../modules/artist/performances/presentation/views/upload_thumbnail_view.dart';
import '../../../modules/artist/performances/presentation/views/upload_performance_details_view.dart';
import '../../../modules/artist/performances/presentation/views/upload_category_tags_view.dart';
import '../../../modules/artist/performances/presentation/views/upload_review_view.dart';
import '../../../modules/artist/performances/presentation/views/upload_success_view.dart';
import '../../../modules/artist/performances/presentation/views/edit_performance_view.dart';
import '../../../modules/artist/performances/presentation/views/artist_live_broadcast_view.dart';
import '../../../modules/artist/performances/presentation/views/artist_go_live_setup_view.dart';
import '../../../modules/artist/performances/presentation/views/artist_session_ended_view.dart';
import '../../../modules/artist/performances/domain/entities/performance_entity.dart';
import '../../../modules/artist/community/presentation/views/artist_create_post_view.dart';
import '../../../modules/artist/community/presentation/views/artist_post_detail_view.dart';
import '../../../modules/artist/community/presentation/views/artist_topic_detail_view.dart';
import '../../../modules/artist/earnings/presentation/views/artist_earnings_view.dart';
import '../../../modules/artist/earnings/presentation/views/artist_wallet_setup_view.dart';
import '../../../modules/artist/community/presentation/views/artist_discussion_detail_view.dart';
import '../../../modules/artist/community/domain/entities/community_post_entity.dart';
import '../../../modules/artist/community/domain/entities/community_topic_entity.dart';
import '../../../modules/artist/profile/presentation/views/artist_edit_profile_view.dart';
import '../../../modules/artist/profile/presentation/views/artist_notification_settings_view.dart';
import '../../../modules/artist/profile/presentation/views/artist_privacy_settings_view.dart';
import '../../../modules/artist/notifications/presentation/views/artist_notifications_view.dart';
import '../../../modules/artist/profile/presentation/views/artist_help_support_view.dart';
import '../../../modules/listner/performances/presentation/views/payment_success_view.dart';
import '../../../modules/legal/presentation/views/terms_and_policies_view.dart';
import '../../../modules/authentication/presentation/views/splash_view.dart';

class AppRouterGo {
  static BuildContext get context =>
      appRouter.routerDelegate.navigatorKey.currentContext!;

  static final appRouter = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            NoTransitionPage(key: state.pageKey, child: const SplashView()),
      ),
      GoRoute(
        path: modeSelectionView,
        pageBuilder: (context, state) =>
            NoTransitionPage(key: state.pageKey, child: const ModeSelectionView()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            NoTransitionPage(key: state.pageKey, child: const OnboardingView()),
      ),
      GoRoute(
        path: loginView,
        pageBuilder: (context, state) =>
            NoTransitionPage(key: state.pageKey, child: const LoginView()),
      ),
      GoRoute(
        path: forgotPasswordView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordView(),
        ),
      ),
      GoRoute(
        path: createNewPasswordView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const CreateNewPasswordView(),
        ),
      ),
      GoRoute(
        path: signupView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ListnerSignupView(),
        ),
      ),
      GoRoute(
        path: profileSetupView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ProfileSetupView(),
        ),
      ),
      GoRoute(
        path: favoriteGenresView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const FavoriteGenresView(),
        ),
      ),
      GoRoute(
        path: dislikedGenresView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const DislikedGenresView(),
        ),
      ),
      GoRoute(
        path: listenerDashboardView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ListenerDashboardView(),
        ),
      ),
      GoRoute(
        path: listenerEditProfileView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ListenerEditProfileView(),
        ),
      ),
      GoRoute(
        path: listenerPreferencesView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ListenerPreferencesView(),
        ),
      ),
      GoRoute(
        path: listenerNotificationsView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ListenerNotificationsView(),
        ),
      ),
      GoRoute(
        path: notificationDetailView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: NotificationDetailView(
            notification: state.extra as NotificationDto,
          ),
        ),
      ),
      GoRoute(
        path: listenerPrivacySettingsView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ListenerPrivacySettingsView(),
        ),
      ),
      GoRoute(
        path: listenerHelpSupportView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ListenerHelpSupportView(),
        ),
      ),
      GoRoute(
        path: listenerLibraryView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: ListenerLibraryView(initialTab: (state.extra as int?) ?? 0),
        ),
      ),
      GoRoute(
        path: listenerSongDetailView,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return NoTransitionPage(
            key: state.pageKey,
            child: LibrarySongDetailView(
              song: extra['song'] as LibrarySongDto,
              isHistory: extra['isHistory'] == true,
            ),
          );
        },
      ),
      GoRoute(
        path: artistProfileView,
        pageBuilder: (context, state) {
          final args = state.extra as ArtistProfileArgs?;
          return NoTransitionPage(
            key: state.pageKey,
            child: ArtistProfileView(
              args: args ?? const ArtistProfileArgs(artistId: '', artistName: 'Artist'),
            ),
          );
        },
      ),
      GoRoute(
        path: listenerCreatePostView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ListenerCreatePostView(),
        ),
      ),
      GoRoute(
        path: listenerGenreCommunityDetailView,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return NoTransitionPage(
            key: state.pageKey,
            child: ListenerGenreCommunityDetailView(
              communityName: extra['communityName'] as String,
              image: extra['image'] as String,
              members: extra['members'] as String,
              posts: extra['posts'] as String,
            ),
          );
        },
      ),
      GoRoute(
        path: listenerDiscussionDetailView,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final queryParams = state.uri.queryParameters;

          final title = extra?['title'] as String? ?? queryParams['title'] ?? 'Discussion';
          final author = extra?['author'] as String? ?? queryParams['author'] ?? '';
          final timeAgo = extra?['timeAgo'] as String? ?? queryParams['timeAgo'] ?? '';
          final tag = extra?['tag'] as String? ?? queryParams['tag'] ?? '';
          final replies = (extra?['replies'] as int?) ?? int.tryParse(queryParams['replies'] ?? '') ?? 0;
          final likes = (extra?['likes'] as int?) ?? int.tryParse(queryParams['likes'] ?? '') ?? 0;
          final body = extra?['body'] as String? ?? queryParams['body'] ?? '';
          final authorAvatarUrl = extra?['authorAvatarUrl'] as String? ?? queryParams['authorAvatarUrl'];
          final postId = extra?['postId'] as String? ?? queryParams['postId'] ?? '';
          final authorId = extra?['authorId'] as String? ?? queryParams['authorId'];

          return NoTransitionPage(
            key: state.pageKey,
            child: ListenerDiscussionDetailView(
              title: title,
              author: author,
              timeAgo: timeAgo,
              tag: tag,
              replies: replies,
              likes: likes,
              body: body,
              authorAvatarUrl: authorAvatarUrl,
              postId: postId,
              authorId: authorId,
            ),
          );
        },
      ),
      GoRoute(
        path: listenerLivePerformanceView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: ListenerLivePerformanceView(
            featured: state.extra as PerformanceFeaturedEntity,
          ),
        ),
      ),
      GoRoute(
        path: listenerUpcomingPerformanceDetailView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: ListenerUpcomingPerformanceDetailView(
            performance: state.extra as PerformanceUpcomingEntity,
          ),
        ),
      ),
      GoRoute(
        path: artistSignupView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ArtistSignupView(),
        ),
      ),
      GoRoute(
        path: artistSetupView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ArtistSetupView(),
        ),
      ),
      GoRoute(
        path: artistDashboardView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ArtistDashboardView(),
        ),
      ),
      GoRoute(
        path: artistScheduleLiveSessionView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ScheduleLiveSessionView(),
        ),
      ),
      GoRoute(
        path: artistScheduleCoverImageView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ScheduleCoverImageView(),
        ),
      ),
      GoRoute(
        path: artistScheduleDateTimeView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ScheduleDateTimeView(),
        ),
      ),
      GoRoute(
        path: artistScheduleCategoryTagsView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ScheduleCategoryTagsView(),
        ),
      ),
      GoRoute(
        path: artistScheduleReviewView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ScheduleReviewView(),
        ),
      ),
      GoRoute(
        path: artistScheduleSuccessView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ScheduleSuccessView(),
        ),
      ),
      GoRoute(
        path: artistUploadVideoView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const UploadVideoView(),
        ),
      ),
      GoRoute(
        path: artistUploadThumbnailView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const UploadThumbnailView(),
        ),
      ),
      GoRoute(
        path: artistUploadPerformanceDetailsView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const UploadPerformanceDetailsView(),
        ),
      ),
      GoRoute(
        path: artistUploadCategoryTagsView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const UploadCategoryTagsView(),
        ),
      ),
      GoRoute(
        path: artistUploadReviewView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const UploadReviewView(),
        ),
      ),
      GoRoute(
        path: artistUploadSuccessView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const UploadSuccessView(),
        ),
      ),
      GoRoute(
        path: artistEditPerformanceView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: EditPerformanceView(
            item: state.extra as PerformanceEntity?,
          ),
        ),
      ),
      GoRoute(
        path: artistEditProfileView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ArtistEditProfileView(),
        ),
      ),
      GoRoute(
        path: artistNotificationSettingsView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ArtistNotificationSettingsView(),
        ),
      ),
      GoRoute(
        path: artistNotificationsView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ArtistNotificationsView(),
        ),
      ),
      GoRoute(
        path: artistPrivacySettingsView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ArtistPrivacySettingsView(),
        ),
      ),
      GoRoute(
        path: artistHelpSupportView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ArtistHelpSupportView(),
        ),
      ),
      GoRoute(
        path: artistGoLiveSetupView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ArtistGoLiveSetupView(),
        ),
      ),
      GoRoute(
        path: artistLiveBroadcastView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: ArtistLiveBroadcastView(
            item: state.extra as PerformanceEntity,
          ),
        ),
      ),
      GoRoute(
        path: artistSessionEndedView,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return NoTransitionPage(
            key: state.pageKey,
            child: ArtistSessionEndedView(
              item: extra['item'] as PerformanceEntity,
              duration: extra['duration'] as String,
            ),
          );
        },
      ),
      GoRoute(
        path: artistCreatePostView,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ArtistCreatePostView(),
        ),
      ),
      GoRoute(
        path: artistPostDetailView,
        pageBuilder: (context, state) {
          final post = state.extra as CommunityPostEntity;
          return NoTransitionPage(
            key: state.pageKey,
            child: ArtistPostDetailView(post: post),
          );
        },
      ),
      GoRoute(
        path: artistTopicDetailView,
        pageBuilder: (context, state) {
          final topic = state.extra as CommunityTopicEntity;
          return NoTransitionPage(
            key: state.pageKey,
            child: ArtistTopicDetailView(topic: topic),
          );
        },
      ),
      GoRoute(
        path: artistDiscussionDetailView,
        pageBuilder: (context, state) {
          final discussion = state.extra as Map<String, dynamic>;
          return NoTransitionPage(
            key: state.pageKey,
            child: ArtistDiscussionDetailView(discussion: discussion),
          );
        },
      ),
      GoRoute(
        path: artistEarningsView,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ArtistEarningsView(),
        ),
      ),
      GoRoute(
        path: artistWalletSetupView,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ArtistWalletSetupView(),
        ),
      ),
      GoRoute(
        path: '/payment-success',
        pageBuilder: (context, state) {
          final sessionId = state.uri.queryParameters['session_id'] ?? '';
          return NoTransitionPage(
            key: state.pageKey,
            child: PaymentSuccessView(sessionId: sessionId),
          );
        },
      ),
      GoRoute(
        path: '/payment-cancelled',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const _PaymentCancelledView(),
        ),
      ),
      GoRoute(
        path: termsAndPoliciesView,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final initialSectionId = extra?['sectionId'] as String?;
          final isArtistMode = extra?['isArtist'] as bool? ?? false;
          return NoTransitionPage(
            key: state.pageKey,
            child: TermsAndPoliciesView(
              initialSectionId: initialSectionId,
              isArtistViewInitial: isArtistMode,
            ),
          );
        },
      ),
    ],
  );

  static void back() {
    if (context.canPop()) {
      context.pop();
    }
  }

  static void push(location, {Object? extra, Function(dynamic)? onThen}) {
    context.push(location, extra: extra).then((value) {
      onThen?.call(value);
    });
  }

  static pushRemoveUntil(location) {
    context.go(location);
  }

  static pushReplacement(location, {Object? extra}) {
    context.replace(location, extra: extra);
  }
}

class _PaymentCancelledView extends StatelessWidget {
  const _PaymentCancelledView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.santagrey.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppColors.santagrey.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.cancel_outlined,
                    color: AppColors.santagrey,
                    size: 36.sp,
                  ),
                ),
                24.ph,
                Text(
                  'Payment Cancelled',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryWhite,
                  ),
                ),
                8.ph,
                Text(
                  'Your payment was cancelled. No charges were made.',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14.sp,
                    color: AppColors.santagrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                32.ph,
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () => context.go('/listener-dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.listenerYellow,
                      foregroundColor: AppColors.primaryblack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'Back to Dashboard',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
