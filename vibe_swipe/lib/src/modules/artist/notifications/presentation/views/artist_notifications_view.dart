import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/artist_notifications_controller.dart';
import '../widgets/artist_notification_card.dart';

class ArtistNotificationsView extends ConsumerWidget {
  const ArtistNotificationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(artistNotificationsControllerProvider);

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
              const ArtistPageHeader(title: 'Notification'),
              Expanded(
                child: controller.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.listenerActiveTab,
                          strokeWidth: 2.5,
                        ),
                      )
                    : controller.notifications.isEmpty
                        ? Center(
                            child: Text(
                              'No notifications yet',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14.sp,
                                color: AppColors.huegrey,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 16.h,
                            ),
                            itemCount: controller.notifications.length,
                            separatorBuilder: (_, __) => 12.ph,
                            itemBuilder: (context, index) => ArtistNotificationCard(
                              notification: controller.notifications[index],
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
