import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/macha_audio_handler.dart';

final audioHandlerProvider = Provider<MachaAudioHandler>((ref) {
  return machaAudioHandler;
});
