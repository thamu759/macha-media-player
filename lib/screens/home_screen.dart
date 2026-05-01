import 'package:flutter/material.dart';
import '../core/permissions.dart';
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
  bool _hasPermissions = false;
  bool _isCheckingPermissions = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final granted = await PermissionManager.requestMediaPermissions();
    setState(() {
      _hasPermissions = granted;
      _isCheckingPermissions = false;
    });
  }

  final List<Widget> _screens = [
    const Center(child: Text('Home (Dashboard / Recent)', style: TextStyle(fontSize: 20))),
    const AudioScreen(),
    const VideoScreen(),
    const PlaylistsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermissions) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_hasPermissions) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Storage permission is required to find media files."),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkPermissions,
                child: const Text("Grant Permissions"),
              ),
            ],
          ),
        ),
      );
    }

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
