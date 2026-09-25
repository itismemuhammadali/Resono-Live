import 'package:vibe_swipe/src/core/services/agora_service.dart';
import 'package:vibe_swipe/src/core/services/local_db_service/secure_storage.dart';
import 'package:vibe_swipe/src/core/services/in_app_purchase_service.dart';
import 'package:vibe_swipe/src/core/services/permission_service.dart';
import 'package:vibe_swipe/src/core/services/python_api_service.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';

final locator = GetIt.instance;

void setupLocator() {
  appPrint("***Setup Registry***");
  locator.registerLazySingleton<Prefs>(() => Prefs());
  locator.registerLazySingleton<Client>(() => Client());
  locator.registerLazySingleton<ApiService>(() => ApiService());
  locator.registerLazySingleton<BaseApiService>(() => locator<ApiService>());
  locator.registerLazySingleton(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(),
      iOptions: IOSOptions.defaultOptions,
    ),
  );
  locator
      .registerLazySingleton<NotificationService>(() => NotificationService());
  locator.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());
  locator.registerLazySingleton<FirestoreService>(() => FirestoreService());
  locator.registerLazySingleton<PythonApiService>(() => PythonApiService());
  locator.registerLazySingleton<AgoraService>(() => AgoraService());
  locator.registerLazySingleton<RemoteConfigService>(() => RemoteConfigService());
  locator.registerLazySingleton<PermissionService>(() => PermissionService());
  locator.registerLazySingleton<InAppPurchaseService>(() => InAppPurchaseService());
}
