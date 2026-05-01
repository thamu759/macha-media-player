import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:just_audio/just_audio.dart';
import '../services/auto_dub_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final AssetEntity video;
  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  
  // Dubbing State
  bool _isDubbing = false;
  String? _dubbedAudioPath;
  final AudioPlayer _dubPlayer = AudioPlayer();
  final AutoDubService _autoDubService = AutoDubService();
  String? _videoFilePath;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final file = await widget.video.file;
    if (file == null) return;
    _videoFilePath = file.path;

    _videoPlayerController = VideoPlayerController.file(file);
    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      allowFullScreen: true,
      allowMuting: true,
    );
    
    _setupSyncListener();
    setState(() {});
  }

  void _setupSyncListener() {
    _videoPlayerController!.addListener(() {
      if (_dubbedAudioPath != null) {
        if (_videoPlayerController!.value.isPlaying && !_dubPlayer.playing) {
          _dubPlayer.play();
        } else if (!_videoPlayerController!.value.isPlaying && _dubPlayer.playing) {
          _dubPlayer.pause();
        }
        
        // Sync seek position if drift > 500ms
        final vPos = _videoPlayerController!.value.position;
        final aPos = _dubPlayer.position;
        if ((vPos.inMilliseconds - aPos.inMilliseconds).abs() > 500) {
          _dubPlayer.seek(vPos);
        }
      }
    });
  }

  Future<void> _startAutoDub() async {
    if (_videoFilePath == null) return;
    
    setState(() => _isDubbing = true);
    
    // Pause video while dubbing
    _chewieController?.pause();

    final dubbedPath = await _autoDubService.generateDubbedAudio(_videoFilePath!);
    
    if (dubbedPath != null) {
      _dubbedAudioPath = dubbedPath;
      await _dubPlayer.setFilePath(dubbedPath);
      // Mute original video
      _videoPlayerController!.setVolume(0.0);
      
      // Seek dub to current video position
      await _dubPlayer.seek(_videoPlayerController!.value.position);
      
      // Resume video
      _chewieController?.play();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dubbing applied successfully!')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Auto Dub failed. Check API Keys.')));
      }
    }
    
    setState(() => _isDubbing = false);
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _dubPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.video.title ?? 'Video'),
        actions: [
          if (_isDubbing)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16), 
                child: SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurpleAccent)
                )
              )
            )
          else
            IconButton(
              icon: const Icon(Icons.auto_awesome, color: Colors.deepPurpleAccent),
              tooltip: "Auto Dub (AI)",
              onPressed: _startAutoDub,
            )
        ],
      ),
      body: Center(
        child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(),
      ),
    );
  }
}
