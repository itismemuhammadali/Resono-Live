import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static const _keyApiBaseUrl = 'python_api_url';
  static const _fallbackApiBaseUrl = 'http://177.7.33.210:8000';

  late final FirebaseRemoteConfig _remoteConfig;
  bool _initialized = false;

  String get apiBaseUrl {
    if (!_initialized) return _fallbackApiBaseUrl;
    final value = _remoteConfig.getString(_keyApiBaseUrl);
    return value.isNotEmpty ? value : _fallbackApiBaseUrl;
  }

  Future<void> init() async {
    _remoteConfig = FirebaseRemoteConfig.instance;

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 5),
        minimumFetchInterval: const Duration(seconds: 0),
      ),
    );

    await _remoteConfig.setDefaults(const {
      _keyApiBaseUrl: _fallbackApiBaseUrl,
    });

    _initialized = true;

    _remoteConfig.fetchAndActivate().catchError((_) {});
  }
}
