import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class PermissionManager {
  static Future<bool> requestMediaPermissions() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      // For Android 13+ (API 33+)
      final audioStatus = await Permission.audio.request();
      final videoStatus = await Permission.videos.request();
      final storageStatus = await Permission.storage.request();

      if (audioStatus.isGranted || videoStatus.isGranted || storageStatus.isGranted) {
        return true;
      }
      return false;
    } else if (Platform.isIOS) {
      final status = await Permission.mediaLibrary.request();
      return status.isGranted;
    }
    return false;
  }
}
