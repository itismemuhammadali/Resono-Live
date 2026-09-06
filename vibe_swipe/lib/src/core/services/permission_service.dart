import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibe_swipe/src/core/services/registry_service/di.dart';
import 'package:vibe_swipe/src/core/utils/app_logger.dart';

class PermissionService {
  static const String _initialPermissionsKey = 'has_requested_initial_permissions';
  final FlutterSecureStorage _storage;

  PermissionService({FlutterSecureStorage? storage})
      : _storage = storage ?? locator<FlutterSecureStorage>();

  Future<bool> hasRequestedInitialPermissions() async {
    try {
      final value = await _storage.read(key: _initialPermissionsKey);
      return value == 'true';
    } catch (e) {
      appPrint('[PermissionService] Error reading initial permissions flag: $e');
      return false;
    }
  }

  Future<void> markInitialPermissionsRequested() async {
    try {
      await _storage.write(key: _initialPermissionsKey, value: 'true');
    } catch (e) {
      appPrint('[PermissionService] Error writing initial permissions flag: $e');
    }
  }

  Future<Map<Permission, PermissionStatus>> requestInitialPermissions() async {
    if (kIsWeb) return {};

    final permissionsToRequest = <Permission>[
      Permission.camera,
      Permission.microphone,
      if (Platform.isIOS) Permission.photos else Permission.storage,
      Permission.notification,
    ];

    final results = <Permission, PermissionStatus>{};
    try {
      for (final permission in permissionsToRequest) {
        final status = await permission.status;
        if (!status.isGranted && !status.isPermanentlyDenied) {
          results[permission] = await permission.request();
        } else {
          results[permission] = status;
        }
      }
      await markInitialPermissionsRequested();
      appPrint('[PermissionService] Initial permissions result: $results');
      return results;
    } catch (e) {
      appPrint('[PermissionService] Error requesting initial permissions: $e');
      await markInitialPermissionsRequested();
      return results;
    }
  }
}
