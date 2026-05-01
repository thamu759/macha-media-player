import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class MachaAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer player = AudioPlayer();

  MachaAudioHandler() {
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  Future<void> playSong(SongModel song) async {
    await Permission.notification.request();

    final item = MediaItem(
      id: song.data,
      title: song.title,
      artist: song.artist?.trim().isNotEmpty == true ? song.artist : 'Unknown Artist',
      album: song.album,
      duration: song.duration == null ? null : Duration(milliseconds: song.duration!),
    );

    mediaItem.add(item);
    await player.setAudioSource(AudioSource.uri(Uri.file(song.data)));
    await player.play();
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> stop() async {
    await player.stop();
    await super.stop();
  }

  @override
  Future<void> fastForward() {
    return seek(player.position + const Duration(seconds: 10));
  }

  @override
  Future<void> rewind() {
    final next = player.position - const Duration(seconds: 10);
    return seek(next < Duration.zero ? Duration.zero : next);
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: event.currentIndex,
    );
  }
}

late MachaAudioHandler machaAudioHandler;
