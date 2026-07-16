import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'src/core/utils/app_exports.dart';
import 'src/core/services/deep_link_service.dart';

final deepLinkService = DeepLinkService();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  appPrint("Background FCM message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    appPrint("Warning: .env file not found, proceeding without it");
  }

  setupLocator();

  try {
    await deepLinkService.init();
  } catch (e) {
    appPrint("Warning: Deep link init failed: $e");
  }

  if (!kIsWeb) {
    locator<NotificationService>().requestPermission().then((_) {
      locator<NotificationService>().init();
    }).catchError((_) {});
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    runApp(ProviderScope(child: VibeSwipeApp()));
  });
}

class VibeSwipeApp extends ConsumerWidget with AppSize, AppTheme {
  const VibeSwipeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: MediaQuery.sizeOf(context).width < 600.0
          ? const Size(440, 956)
          : Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
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
