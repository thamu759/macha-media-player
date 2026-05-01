import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/playlist_provider.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistProvider);

    return Scaffold(
      body: playlists.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.playlist_add, size: 100, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No Playlists Created', style: TextStyle(fontSize: 20, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showCreatePlaylistDialog(context, ref),
                    child: const Text('Create New Playlist'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return Card(
                  color: Colors.white10,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.playlist_play, color: Colors.white),
                    ),
                    title: Text(playlist.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${playlist.mediaPaths.length} items'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to playlist details (future)
                    },
                  ),
                );
              },
            ),
      floatingActionButton: playlists.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showCreatePlaylistDialog(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Playlist Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(playlistProvider.notifier).createPlaylist(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
