import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:photo_manager/photo_manager.dart';
import '../core/permissions.dart';

final audioQueryProvider = Provider((ref) => OnAudioQuery());

final audioListProvider = FutureProvider<List<SongModel>>((ref) async {
  try {
    final audioQuery = ref.watch(audioQueryProvider);
    
    // Specifically request audio permissions with a timeout
    final hasPermission = await PermissionManager.requestAudioPermission()
        .timeout(const Duration(seconds: 3), onTimeout: () => false);

    if (!hasPermission) {
      return [];
    }

    return await audioQuery.querySongs(
      sortType: null,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    ).timeout(const Duration(seconds: 10), onTimeout: () => []);
  } catch (e) {
    debugPrint("Audio Error: $e");
    return [];
  }
});

final videoListProvider = FutureProvider<List<AssetEntity>>((ref) async {
  try {
    final hasPermission = await PermissionManager.requestVideoPermission()
        .timeout(const Duration(seconds: 3), onTimeout: () => false);
    
    if (hasPermission) {
      final albums = await PhotoManager.getAssetPathList(type: RequestType.video)
          .timeout(const Duration(seconds: 10), onTimeout: () => []);
      if (albums.isNotEmpty) {
        final recentAlbum = albums.first;
        final videos = await recentAlbum.getAssetListPaged(page: 0, size: 100);
        return videos;
      }
    }
  } catch (e) {
    debugPrint("Video Error: $e");
  }
  return [];
});
