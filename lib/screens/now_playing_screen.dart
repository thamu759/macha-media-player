import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../providers/audio_player_provider.dart';
import '../services/macha_audio_handler.dart';

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
    final audioHandler = ref.read(audioHandlerProvider);
    try {
      await audioHandler.playSong(widget.song);
    } catch (e) {
      debugPrint("Error loading audio source: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioHandler = ref.watch(audioHandlerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00B8A9).withValues(alpha: 0.18),
                      blurRadius: 34,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: QueryArtworkWidget(
                    id: widget.song.id,
                    type: ArtworkType.AUDIO,
                    artworkWidth: 280,
                    artworkHeight: 280,
                    artworkFit: BoxFit.cover,
                    nullArtworkWidget: Container(
                      width: 280,
                      height: 280,
                      color: const Color(0xFF171A1F),
                      child: const Icon(
                        Icons.music_note,
                        size: 112,
                        color: Color(0xFF00B8A9),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 34),
              Text(
                widget.song.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                widget.song.artist?.trim().isNotEmpty == true
                    ? widget.song.artist!
                    : 'Unknown Artist',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.62),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              _PlayerPanel(audioHandler: audioHandler),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerPanel extends StatelessWidget {
  final MachaAudioHandler audioHandler;

  const _PlayerPanel({required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF171A1F),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          StreamBuilder<Duration>(
            stream: audioHandler.player.positionStream,
            builder: (context, positionSnapshot) {
              return StreamBuilder<Duration?>(
                stream: audioHandler.player.durationStream,
                builder: (context, durationSnapshot) {
                  final position = positionSnapshot.data ?? Duration.zero;
                  final duration = durationSnapshot.data ?? Duration.zero;
                  final max = duration.inMilliseconds.toDouble().clamp(1, double.infinity);
                  final value = position.inMilliseconds.toDouble().clamp(0, max);

                  return Column(
                    children: [
                      Slider(
                        value: value.toDouble(),
                        max: max.toDouble(),
                        onChanged: (nextValue) {
                          audioHandler.seek(Duration(milliseconds: nextValue.round()));
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(position), style: _timeStyle),
                          Text(_formatDuration(duration), style: _timeStyle),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 8),
          StreamBuilder<PlayerState>(
            stream: audioHandler.player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing ?? false;

              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                return const SizedBox(
                  width: 64,
                  height: 64,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final icon = processingState == ProcessingState.completed
                  ? Icons.replay_rounded
                  : playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: "Back",
                    icon: const Icon(Icons.replay_10_rounded),
                    onPressed: () {
                      final next = audioHandler.player.position - const Duration(seconds: 10);
                      audioHandler.seek(next < Duration.zero ? Duration.zero : next);
                    },
                  ),
                  const SizedBox(width: 18),
                  FilledButton(
                    onPressed: () {
                      if (processingState == ProcessingState.completed) {
                        audioHandler.seek(Duration.zero);
                        audioHandler.play();
                      } else if (playing) {
                        audioHandler.pause();
                      } else {
                        audioHandler.play();
                      }
                    },
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      fixedSize: const Size(68, 68),
                      padding: EdgeInsets.zero,
                    ),
                    child: Icon(icon, size: 40),
                  ),
                  const SizedBox(width: 18),
                  IconButton(
                    tooltip: "Forward",
                    icon: const Icon(Icons.forward_10_rounded),
                    onPressed: () {
                      audioHandler.seek(audioHandler.player.position + const Duration(seconds: 10));
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

final _timeStyle = TextStyle(
  color: Colors.white.withValues(alpha: 0.58),
  fontSize: 12,
  fontWeight: FontWeight.w600,
);

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString();
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final hours = duration.inHours;
  if (hours > 0) return "$hours:${minutes.padLeft(2, '0')}:$seconds";
  return "$minutes:$seconds";
}
