import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_audio/return_code.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

class AutoDubService {
  final _box = Hive.box('settings');
  
  String get openAiApiKey => _box.get('openai_key', defaultValue: "");
  String get elevenLabsApiKey => _box.get('elevenlabs_key', defaultValue: "");
  final String elevenLabsVoiceId = "pNInz6obpgDQGcFmaJcg"; // Default voice ID

  Future<String?> generateDubbedAudio(String videoPath) async {
    try {
      // 1. Extract Audio
      final extractedAudioPath = await _extractAudio(videoPath);
      if (extractedAudioPath == null) return null;

      // 2. Transcribe using Whisper
      final transcription = await _transcribeAudio(extractedAudioPath);
      if (transcription == null) return null;

      // 3. Generate Dub using ElevenLabs
      final dubbedAudioPath = await _generateVoice(transcription);
      return dubbedAudioPath;
    } catch (e) {
      print("Error in Auto Dub: $e");
      return null;
    }
  }

  Future<String?> _extractAudio(String videoPath) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/extracted_audio_${DateTime.now().millisecondsSinceEpoch}.wav';

    // ffmpeg command to extract audio
    final command = '-y -i "$videoPath" -vn -acodec pcm_s16le -ar 44100 -ac 2 "$outputPath"';
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return outputPath;
    }
    return null;
  }

  Future<String?> _transcribeAudio(String audioPath) async {
    final dio = Dio();
    dio.options.headers["Authorization"] = "Bearer $openAiApiKey";
    
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(audioPath),
      "model": "whisper-1",
    });

    try {
      final response = await dio.post(
        "https://api.openai.com/v1/audio/transcriptions", 
        data: formData,
      );
      return response.data['text'];
    } catch (e) {
      print("Whisper Error: $e");
      return null;
    }
  }

  Future<String?> _generateVoice(String text) async {
    final dio = Dio();
    dio.options.headers["xi-api-key"] = elevenLabsApiKey;
    dio.options.headers["Content-Type"] = "application/json";

    try {
      final response = await dio.post(
        "https://api.elevenlabs.io/v1/text-to-speech/$elevenLabsVoiceId",
        data: {
          "text": text,
          "model_id": "eleven_monolingual_v1",
          "voice_settings": {
            "stability": 0.5,
            "similarity_boost": 0.5
          }
        },
        options: Options(responseType: ResponseType.bytes),
      );

      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/dubbed_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
      
      final file = File(outputPath);
      await file.writeAsBytes(response.data);
      return outputPath;
    } catch (e) {
      print("ElevenLabs Error: $e");
      return null;
    }
  }
}
