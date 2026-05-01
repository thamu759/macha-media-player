import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/permissions.dart';
import '../providers/media_provider.dart';
import 'video_player_screen.dart';

class VideoScreen extends ConsumerWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoListAsync = ref.watch(videoListProvider);

    return Scaffold(
      body: videoListAsync.when(
        data: (videos) {
          if (videos.isEmpty) {
            return _PermissionEmptyState(
              message: "Video files varala. Permission allow pannitu retry pannunga.",
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
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
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
