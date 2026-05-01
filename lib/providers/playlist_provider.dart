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

class PlaylistNotifier extends Notifier<List<Playlist>> {
  @override
  List<Playlist> build() {
    // We can't call _loadPlaylists here because it sets state
    // Instead we return the loaded data
    final box = Hive.box('playlists');
    final data = box.values.toList();
    return data.map((e) => Playlist.fromMap(e as Map)).toList();
  }

  void _refresh() {
    final box = Hive.box('playlists');
    final data = box.values.toList();
    state = data.map((e) => Playlist.fromMap(e as Map)).toList();
  }

  Future<void> createPlaylist(String name) async {
    final box = Hive.box('playlists');
    final newPlaylist = Playlist(name: name, mediaPaths: []);
    await box.add(newPlaylist.toMap());
    _refresh();
  }

  Future<void> addToPlaylist(int index, String path) async {
    final box = Hive.box('playlists');
    final playlist = state[index];
    if (!playlist.mediaPaths.contains(path)) {
      playlist.mediaPaths.add(path);
      await box.putAt(index, playlist.toMap());
      _refresh();
    }
  }
}

final playlistProvider = NotifierProvider<PlaylistNotifier, List<Playlist>>(() {
  return PlaylistNotifier();
});
