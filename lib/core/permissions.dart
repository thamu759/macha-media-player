import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class PermissionManager {
  static Future<List<Permission>> get _requiredPermissions async {
    if (Platform.isIOS) return [Permission.mediaLibrary];
    
    // For Android 13 (API 33) and above
    if (Platform.isAndroid) {
      // We can't easily check API level here without another package, 
      // but we can request both and handle the results.
      // Newer Android needs these:
      return [
        Permission.audio,
        Permission.videos,
        Permission.photos,
      ];
    }
    return [Permission.storage];
  }

  static Future<bool> hasMediaPermissions() async {
    if (kIsWeb) return false;

    try {
      final permissions = await _requiredPermissions;
      for (var permission in permissions) {
        final status = await permission.status;
        if (status.isGranted || status.isLimited) return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  static Future<bool> requestMediaPermissions() async {
    if (kIsWeb) return false;

    try {
      final permissions = await _requiredPermissions;
      
      // Requesting them one by one or as a map
      Map<Permission, PermissionStatus> statuses = await permissions.request();
      
      // On Android 13+, 'storage' will be denied, but 'audio'/'videos' might be granted.
      // So we check if ANY media permission is granted.
      return statuses.values.any((status) => status.isGranted || status.isLimited);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openPermissionSettings() {
    return openAppSettings();
  }
}
