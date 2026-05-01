import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Playlist {
  final String name;
  final List<String> mediaPaths;

  Playlist({required this.name, required this.mediaPaths});

  Map<String, dynamic> toMap() => {
        'name': name,
        'mediaPaths': mediaPaths,
      };

  factory Playlist.fromMap(Map<dynamic, dynamic> map) => Playlist(
        name: map['name'] as String,
        mediaPaths: List<String>.from(map['mediaPaths'] as List),
      );
}

class PlaylistNotifier extends StateNotifier<List<Playlist>> {
  PlaylistNotifier() : super([]) {
    _loadPlaylists();
  }

  final _box = Hive.box('playlists');

  void _loadPlaylists() {
    final data = _box.values.toList();
    state = data.map((e) => Playlist.fromMap(e as Map)).toList();
  }

  Future<void> createPlaylist(String name) async {
    final newPlaylist = Playlist(name: name, mediaPaths: []);
    await _box.add(newPlaylist.toMap());
    _loadPlaylists();
  }

  Future<void> addToPlaylist(int index, String path) async {
    final playlist = state[index];
    if (!playlist.mediaPaths.contains(path)) {
      playlist.mediaPaths.add(path);
      await _box.putAt(index, playlist.toMap());
      _loadPlaylists();
    }
  }
}

final playlistProvider = StateNotifierProvider<PlaylistNotifier, List<Playlist>>((ref) {
  return PlaylistNotifier();
});
