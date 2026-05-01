import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class PermissionManager {
  static Future<bool> requestAudioPermission() async {
    if (kIsWeb) return false;
    try {
      if (Platform.isAndroid) {
        final statuses = await [Permission.audio, Permission.storage].request();
        final audioStatus = statuses[Permission.audio] ?? PermissionStatus.denied;
        final storageStatus = statuses[Permission.storage] ?? PermissionStatus.denied;
        return audioStatus.isGranted || storageStatus.isGranted;
      }
      return await Permission.mediaLibrary.request().isGranted;
    } catch (e) {
      debugPrint("Permission Error: $e");
      return false;
    }
  }

  static Future<bool> requestVideoPermission() async {
    if (kIsWeb) return false;
    try {
      if (Platform.isAndroid) {
        final statuses = await [Permission.videos, Permission.storage].request();
        final videoStatus = statuses[Permission.videos] ?? PermissionStatus.denied;
        final storageStatus = statuses[Permission.storage] ?? PermissionStatus.denied;
        return videoStatus.isGranted || storageStatus.isGranted;
      }
      return await Permission.mediaLibrary.request().isGranted;
    } catch (e) {
      debugPrint("Permission Error: $e");
      return false;
    }
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
