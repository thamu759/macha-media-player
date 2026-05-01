import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../core/permissions.dart';
import '../providers/media_provider.dart';
import 'now_playing_screen.dart';

class AudioScreen extends ConsumerWidget {
  const AudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioListAsync = ref.watch(audioListProvider);

    return Scaffold(
      body: audioListAsync.when(
        data: (songs) {
          if (songs.isEmpty) {
            return _PermissionEmptyState(
              message: "Audio files varala. Permission allow pannitu retry pannunga.",
              onRetry: () => ref.invalidate(audioListProvider),
            );
          }
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                leading: QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: const Icon(Icons.music_note, size: 50),
                ),
                title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(song.artist ?? "Unknown Artist"),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => NowPlayingScreen(song: song)));
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _PermissionEmptyState(
          message: 'Audio load aagala: $err',
          onRetry: () => ref.invalidate(audioListProvider),
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
