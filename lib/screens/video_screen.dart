import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/permissions.dart';
import '../providers/media_provider.dart';
import 'video_player_screen.dart';

class VideoScreen extends ConsumerStatefulWidget {
  const VideoScreen({super.key});

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final videoListAsync = ref.watch(videoListProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: "Search videos...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
        ),
      ),
      body: videoListAsync.when(
        data: (videos) {
          final filteredVideos = videos.where((v) => (v.title ?? "").toLowerCase().contains(_searchQuery.toLowerCase())).toList();
          
          if (filteredVideos.isEmpty) {
            return _PermissionEmptyState(
              message: _searchQuery.isEmpty ? "Video files varala. Permission allow pannitu retry pannunga." : "No results found.",
              onRetry: () => ref.invalidate(videoListProvider),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: filteredVideos.length,
            itemBuilder: (context, index) {
              final video = filteredVideos[index];
              return FutureBuilder<Color?>(
                future: video.thumbnailData.then((data) => null), // Temporary placeholder for thumbnail logic
                builder: (context, snapshot) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)));
                    },
                    child: Card(
                      elevation: 4,
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(color: Colors.grey[800], child: const Icon(Icons.videocam, size: 50)),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black54,
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                video.title ?? "Video $index",
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _PermissionEmptyState(
          message: 'Video load aagala: $err',
          onRetry: () => ref.invalidate(videoListProvider),
        ),
      ),
    );
  }
}

class _PermissionEmptyState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PermissionEmptyState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Retry"),
            ),
            TextButton(
              onPressed: PermissionManager.openPermissionSettings,
              child: const Text("Open Settings"),
            ),
          ],
        ),
      ),
    );
  }
}
