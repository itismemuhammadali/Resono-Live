// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'notification_navigation_service.dart';

class NotificationService {
  static Future<NotificationSettings>? _permissionRequestInFlight;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'VibeSwipe Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  Future<void> init() async {
    await _initLocalNotifications();

    FirebaseMessaging.onMessage.listen((message) async {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await showNotification(message);
        appPrint("FCM foreground message received");
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      appPrint("App opened from notification: ${message.messageId}");
      NotificationNavigationService.handleNotificationTap(message.data);
    });

    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      appPrint("App launched from terminated state via notification");
      NotificationNavigationService.pendingNotificationData = initialMessage.data;
    }

    await saveTokenToFirestore();
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          appPrint('Notification tapped with payload: ${response.payload}');
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> showNotification(RemoteMessage message) async {
    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const iosDetails = DarwinNotificationDetails(
      presentBadge: true,
      presentAlert: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: details,
      payload: message.data.toString(),
    );
  }

  Future<NotificationSettings> requestPermission() async {
    if (_permissionRequestInFlight != null) {
      return _permissionRequestInFlight!;
    }

    final requestFuture = _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
      provisional: false,
    );

    _permissionRequestInFlight = requestFuture;

    final NotificationSettings settings;
    try {
      settings = await requestFuture;
    } finally {
      _permissionRequestInFlight = null;
    }

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        appPrint("Notification permission: authorized");
        break;
      case AuthorizationStatus.provisional:
        appPrint("Notification permission: provisional");
        break;
      default:
        appPrint("Notification permission: not authorized or denied");
        break;
    }

    return settings;
  }

  Future<String> getDeviceToken() async {
    try {
      return await _messaging.getToken() ?? '';
    } catch (e) {
      appPrint("Failed to get FCM token: $e");
      return '';
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    appPrint("Subscribed to topic: $topic");
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    appPrint("Unsubscribed from topic: $topic");
  }

  Future<void> saveTokenToFirestore() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'fcmToken': token}, SetOptions(merge: true));

      _messaging.onTokenRefresh.listen((newToken) async {
        final currentUid = FirebaseAuth.instance.currentUser?.uid;
        if (currentUid != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUid)
              .set({'fcmToken': newToken}, SetOptions(merge: true));
        }
      });
    } catch (e) {
      appPrint("Failed to save FCM token: $e");
    }
  }
}
