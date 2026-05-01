import 'package:flutter/material.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.playlist_play, size: 100, color: Colors.grey),
            SizedBox(height: 16),
            Text('Custom Playlists', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Feature coming soon in the next update!', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
