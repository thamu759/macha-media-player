import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../core/permissions.dart';
import '../providers/media_provider.dart';
import 'now_playing_screen.dart';

class AudioScreen extends ConsumerStatefulWidget {
  const AudioScreen({super.key});

  @override
  ConsumerState<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends ConsumerState<AudioScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final audioListAsync = ref.watch(audioListProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: "Search audio...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
        ),
      ),
      body: audioListAsync.when(
        data: (songs) {
          final filteredSongs = songs.where((s) => s.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
          
          if (filteredSongs.isEmpty) {
            return _PermissionEmptyState(
              message: _searchQuery.isEmpty ? "Audio files varala. Permission allow pannitu retry pannunga." : "No results found.",
              onRetry: () => ref.invalidate(audioListProvider),
            );
          }
          return ListView.builder(
            itemCount: filteredSongs.length,
            itemBuilder: (context, index) {
              final song = filteredSongs[index];
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
