import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class PermissionManager {
  static Future<bool> requestMediaPermissions() async {
    if (kIsWeb) return false;

    try {
      if (Platform.isAndroid) {
        final statuses = await [
          Permission.audio,
          Permission.videos,
          Permission.storage,
        ].request().timeout(const Duration(seconds: 10));

        return statuses.values.any((status) => status.isGranted || status.isLimited);
      } else if (Platform.isIOS) {
        final status = await Permission.mediaLibrary
            .request()
            .timeout(const Duration(seconds: 10));
        return status.isGranted || status.isLimited;
      }
    } catch (_) {
      return false;
    }

    return false;
  }
}
