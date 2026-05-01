import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class PermissionManager {
  static List<Permission> get _androidMediaPermissions => [
        Permission.audio,
        Permission.videos,
        Permission.storage,
      ];

  static Future<bool> hasMediaPermissions() async {
    if (kIsWeb) return false;

    try {
      if (Platform.isAndroid) {
        final statuses = await Future.wait(
          _androidMediaPermissions.map((permission) => permission.status),
        );
        return statuses.any((status) => status.isGranted || status.isLimited);
      } else if (Platform.isIOS) {
        final status = await Permission.mediaLibrary.status;
        return status.isGranted || status.isLimited;
      }
    } catch (_) {
      return false;
    }

    return false;
  }

  static Future<bool> requestMediaPermissions() async {
    if (kIsWeb) return false;

    try {
      if (await hasMediaPermissions()) return true;

      if (Platform.isAndroid) {
        final statuses = await _androidMediaPermissions.request();

        return statuses.values.any((status) => status.isGranted || status.isLimited);
      } else if (Platform.isIOS) {
        final status = await Permission.mediaLibrary.request();
        return status.isGranted || status.isLimited;
      }
    } catch (_) {
      return false;
    }

    return false;
  }

  static Future<bool> openPermissionSettings() {
    return openAppSettings();
  }
}
