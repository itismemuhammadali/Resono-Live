import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/listener_profile_controller.dart';
import '../widgets/notification_list_tile.dart';

class ListenerNotificationsView extends ConsumerWidget {
  const ListenerNotificationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(listenerProfileControllerProvider);
    final notifications = controller.notifications;

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
              const ListenerPageHeader(title: 'Notifications'),
              10.ph,
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.huegrey,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => 12.ph,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return NotificationListTile(
                            notification: notification,
                            onTap: () => AppRouterGo.push(
                              notificationDetailView,
                              extra: notification,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
