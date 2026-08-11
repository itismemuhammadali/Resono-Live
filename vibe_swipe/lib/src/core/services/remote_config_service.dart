import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vibe_swipe/src/core/utils/app_logger.dart';

class RemoteConfigService {
  static const String _keyStripePublishableKey = 'stripe_publishable_key';
  static const String _keyPythonApiUrl = 'python_api_url';
  static const String _keyBaseUrl = 'base_url';
  static const String _keyAgoraAppId = 'agora_app_id';
  static const String _keyAgoraChannelName = 'agora_channel_name';
  static const String _keyAgoraTestMode = 'agora_test_mode';

  static const String _fallbackStripeKey =
      'pk_test_51TooRKBrWQCE4vcjxkNxPRlMIj1fP3hklfphBbMZD8KxgkYqENCrQcfupwCey9K7kuCr2hpWwoXMyYxDLuGmH6sG00FezFYMJ6';
  static const String _fallbackApiUrl = 'http://177.7.33.210:8000';
  static const String _fallbackAgoraAppId = '88eca28baa1f457fa1d05bcf58f9dfec';
  static const String _fallbackAgoraChannel = 'live-stream-test';

  late final FirebaseRemoteConfig _remoteConfig;
  bool _initialized = false;

  String get stripePublishableKey {
    if (_initialized) {
      final val = _remoteConfig.getString(_keyStripePublishableKey);
      if (val.trim().isNotEmpty) return val.trim();
    }
    return dotenv.maybeGet('STRIPE_PUBLISHABLE_KEY') ?? _fallbackStripeKey;
  }

  String get pythonApiUrl {
    if (_initialized) {
      final val = _remoteConfig.getString(_keyPythonApiUrl);
      if (val.trim().isNotEmpty) return val.trim();
    }
    final envVal = dotenv.maybeGet('PYTHON_API_URL');
    if (envVal != null && envVal.trim().isNotEmpty) return envVal.trim();
    final envBase = dotenv.maybeGet('BASE_URL');
    if (envBase != null && envBase.trim().isNotEmpty) return envBase.trim();
    return _fallbackApiUrl;
  }

  String get baseUrl {
    if (_initialized) {
      final val = _remoteConfig.getString(_keyBaseUrl);
      if (val.trim().isNotEmpty) return val.trim();
    }
    final envBase = dotenv.maybeGet('BASE_URL');
    if (envBase != null && envBase.trim().isNotEmpty) return envBase.trim();
    final envVal = dotenv.maybeGet('PYTHON_API_URL');
    if (envVal != null && envVal.trim().isNotEmpty) return envVal.trim();
    return _fallbackApiUrl;
  }

  String get agoraAppId {
    if (_initialized) {
      final val = _remoteConfig.getString(_keyAgoraAppId);
      if (val.trim().isNotEmpty) return val.trim();
    }
    return dotenv.maybeGet('AGORA_APP_ID') ?? _fallbackAgoraAppId;
  }

  String get agoraChannelName {
    if (_initialized) {
      final val = _remoteConfig.getString(_keyAgoraChannelName);
      if (val.trim().isNotEmpty) return val.trim();
    }
    return dotenv.maybeGet('AGORA_CHANNEL_NAME') ?? _fallbackAgoraChannel;
  }

  bool get agoraTestMode {
    if (_initialized) {
      final val = _remoteConfig.getString(_keyAgoraTestMode);
      if (val.trim().isNotEmpty) return val.trim().toLowerCase() == 'true';
    }
    final envVal = dotenv.maybeGet('AGORA_TEST_MODE');
    return envVal?.trim().toLowerCase() == 'true';
  }

  Future<void> init() async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero, // Always fetch latest config on startup
        ),
      );

      await _remoteConfig.setDefaults(const {
        _keyStripePublishableKey: _fallbackStripeKey,
        _keyPythonApiUrl: _fallbackApiUrl,
        _keyBaseUrl: _fallbackApiUrl,
        _keyAgoraAppId: _fallbackAgoraAppId,
        _keyAgoraChannelName: _fallbackAgoraChannel,
        _keyAgoraTestMode: 'false',
      });

      await _remoteConfig.fetchAndActivate();
      _initialized = true;
      appPrint('[RemoteConfig] Fetched and activated successfully.');
    } catch (e) {
      _initialized = false;
      appPrint('[RemoteConfig] Failed to fetch remote config: $e');
    }
  }
}
