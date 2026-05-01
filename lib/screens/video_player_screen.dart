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
  String _dubStatus = "";
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
    
    setState(() {
      _isDubbing = true;
      _dubStatus = "Extracting Audio...";
    });
    
    _chewieController?.pause();

    try {
      // 1. Extraction (Fast)
      final dubbedPath = await _autoDubService.generateDubbedAudio(_videoFilePath!);
      
      if (dubbedPath != null) {
        setState(() => _dubStatus = "Finalizing...");
        _dubbedAudioPath = dubbedPath;
        await _dubPlayer.setFilePath(dubbedPath);
        _videoPlayerController!.setVolume(0.0);
        await _dubPlayer.seek(_videoPlayerController!.value.position);
        _chewieController?.play();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI Dubbing applied successfully!')));
        }
      } else {
        throw Exception("Failed to generate dub");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auto Dub failed: $e')));
      }
    } finally {
      setState(() {
        _isDubbing = false;
        _dubStatus = "";
      });
    }
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
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16), 
                child: Row(
                  children: [
                    Text(_dubStatus, style: const TextStyle(fontSize: 12, color: Colors.deepPurpleAccent)),
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 16, 
                      height: 16, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurpleAccent)
                    ),
                  ],
                ),
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
