import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:convert';
import 'firebase_options.dart';
import 'src/core/utils/app_exports.dart';
import 'src/core/services/deep_link_service.dart';
import 'src/core/services/in_app_purchase_service.dart';

final deepLinkService = DeepLinkService();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'VibeSwipe Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );
  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  const details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  final localNotifications = FlutterLocalNotificationsPlugin();
  await localNotifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  await localNotifications.show(
    id: message.hashCode,
    title: message.notification?.title,
    body: message.notification?.body,
    notificationDetails: details,
    payload: jsonEncode(message.data),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase first
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    appPrint("Warning: Firebase.initializeApp failed: $e");
  }

  // 2. Set up background messaging handler after Firebase is initialized
  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    appPrint("Warning: FirebaseMessaging.onBackgroundMessage failed: $e");
  }

  // 3. Load .env file
  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    appPrint("Warning: .env file not found, proceeding with RemoteConfig fallbacks");
  }

  // 4. Register services in GetIt
  setupLocator();

  // 5. Initialize Firebase Remote Config (with 3s timeout to prevent startup hangs)
  try {
    final remoteConfig = locator<RemoteConfigService>();
    await remoteConfig.init().timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        appPrint("[RemoteConfig] Init timed out, using fallback values");
      },
    );

    // Initialize Stripe SDK only on non-iOS platforms (Android/Web)
    if (kIsWeb || !Platform.isIOS) {
      final stripeKey = remoteConfig.stripePublishableKey;
      if (stripeKey.isNotEmpty) {
        Stripe.publishableKey = stripeKey;
        appPrint("[Stripe] Initialized from RemoteConfig with key: ${stripeKey.substring(0, stripeKey.length > 8 ? 8 : stripeKey.length)}...");
      } else {
        appPrint("[Stripe] Warning: STRIPE_PUBLISHABLE_KEY not found in RemoteConfig or .env");
      }
    }
  } catch (e) {
    appPrint("Warning: RemoteConfig / Stripe init failed: $e");
  }

  // 6. Deep link service (with 2s timeout)
  try {
    await deepLinkService.init().timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        appPrint("[DeepLink] Init timed out, continuing");
      },
    );
  } catch (e) {
    appPrint("Warning: Deep link init failed: $e");
  }

  // 7. Notification service
  if (!kIsWeb) {
    locator<NotificationService>().requestPermission().then((_) {
      locator<NotificationService>().init();
    }).catchError((_) {});

    // 8. Initialize In-App Purchases on mobile
    locator<InAppPurchaseService>().initialize().catchError((e) {
      appPrint("[IAP] Init failed: $e");
    });
  }

  // 8. Lock device orientations and launch UI unconditionally
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    appPrint("Warning: setPreferredOrientations failed: $e");
  }

  runApp(const ProviderScope(child: VibeSwipeApp()));
}

class VibeSwipeApp extends ConsumerWidget with AppSize, AppTheme {
  const VibeSwipeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: MediaQuery.sizeOf(context).width < 600.0
          ? const Size(440, 956)
          : const Size(768, 1024),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouterGo.appRouter,
          title: AppStrings.vibeSwipe,
          theme: lightTheme,
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling);
            return MediaQuery(
              data: mediaQueryData,
              child: SafeArea(
                top: false,
                left: false,
                right: false,
                bottom: false,
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}
