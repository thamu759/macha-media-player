import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'services/macha_audio_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('playlists');
  machaAudioHandler = await AudioService.init<MachaAudioHandler>(
    builder: MachaAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.macha.mediaplayer.audio',
      androidNotificationChannelName: 'Macha Player',
      androidStopForegroundOnPause: false,
    ),
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Macha Media Player',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
