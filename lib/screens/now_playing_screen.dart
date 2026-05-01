import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../providers/audio_player_provider.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  final SongModel song;
  const NowPlayingScreen({super.key, required this.song});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final player = ref.read(audioPlayerProvider);
    try {
      await player.setAudioSource(AudioSource.uri(Uri.parse('file://${widget.song.data}')));
      player.play();
    } catch (e) {
      debugPrint("Error loading audio source: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(audioPlayerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QueryArtworkWidget(
              id: widget.song.id,
              type: ArtworkType.AUDIO,
              artworkWidth: 250,
              artworkHeight: 250,
              artworkFit: BoxFit.cover,
              nullArtworkWidget: const Icon(Icons.music_note, size: 250),
            ),
            const SizedBox(height: 32),
            Text(widget.song.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text(widget.song.artist ?? 'Unknown Artist', style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 32),
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing;
                if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                  return const CircularProgressIndicator();
                } else if (playing != true) {
                  return IconButton(
                    icon: const Icon(Icons.play_circle_filled),
                    iconSize: 64,
                    onPressed: player.play,
                  );
                } else if (processingState != ProcessingState.completed) {
                  return IconButton(
                    icon: const Icon(Icons.pause_circle_filled),
                    iconSize: 64,
                    onPressed: player.pause,
                  );
                } else {
                  return IconButton(
                    icon: const Icon(Icons.replay_circle_filled),
                    iconSize: 64,
                    onPressed: () => player.seek(Duration.zero),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
