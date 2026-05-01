import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:photo_manager/photo_manager.dart';
import '../core/permissions.dart';

final audioQueryProvider = Provider((ref) => OnAudioQuery());

final audioListProvider = FutureProvider<List<SongModel>>((ref) async {
  final audioQuery = ref.read(audioQueryProvider);
  
  // Specifically request audio permissions
  final hasPermission = await PermissionManager.requestAudioPermission();

  if (!hasPermission) {
    return [];
  }

  return await audioQuery.querySongs(
    sortType: null,
    orderType: OrderType.ASC_OR_SMALLER,
    uriType: UriType.EXTERNAL,
    ignoreCase: true,
  );
});

final videoListProvider = FutureProvider<List<AssetEntity>>((ref) async {
  // Specifically request video permissions
  final hasPermission = await PermissionManager.requestVideoPermission();
  
  if (hasPermission) {
    final albums = await PhotoManager.getAssetPathList(type: RequestType.video);
    if (albums.isNotEmpty) {
      final recentAlbum = albums.first;
      final videos = await recentAlbum.getAssetListPaged(page: 0, size: 100);
      return videos;
    }
  }
  return [];
});
