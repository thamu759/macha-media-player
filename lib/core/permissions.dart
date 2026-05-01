import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class PermissionManager {
  static Future<bool> requestAudioPermission() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      // Try both for compatibility across OS versions
      final statuses = await [Permission.audio, Permission.storage].request();
      return statuses[Permission.audio]!.isGranted || statuses[Permission.storage]!.isGranted;
    }
    return await Permission.mediaLibrary.request().isGranted;
  }

  static Future<bool> requestVideoPermission() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final statuses = await [Permission.videos, Permission.storage].request();
      return statuses[Permission.videos]!.isGranted || statuses[Permission.storage]!.isGranted;
    }
    return await Permission.mediaLibrary.request().isGranted;
  }

  static Future<bool> requestMediaPermissions() async {
    // Legacy method for backward compatibility in the app
    final audio = await requestAudioPermission();
    final video = await requestVideoPermission();
    return audio || video;
  }

  static Future<bool> openPermissionSettings() {
    return openAppSettings();
  }
}
