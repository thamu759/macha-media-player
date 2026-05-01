import 'package:flutter/material.dart';
import 'audio_screen.dart';
import 'video_screen.dart';
import 'playlists_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Center(child: Text('Home (Dashboard / Recent)', style: TextStyle(fontSize: 20))),
    const AudioScreen(),
    const VideoScreen(),
    const PlaylistsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Macha Player', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          )
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.audiotrack), label: 'Audio'),
          NavigationDestination(icon: Icon(Icons.video_library), label: 'Video'),
          NavigationDestination(icon: Icon(Icons.playlist_play), label: 'Playlists'),
        ],
      ),
    );
  }
}
