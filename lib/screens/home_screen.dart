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
  bool _isRequestingPermissions = false;
  String? _permissionMessage;

  @override
  void initState() {
    super.initState();
    _checkPermissions(autoRequest: true);
  }

  Future<void> _checkPermissions({bool autoRequest = false}) async {
    bool granted = false;

    try {
      granted = await PermissionManager.hasMediaPermissions()
          .timeout(const Duration(seconds: 5), onTimeout: () => false);
    } catch (_) {
      granted = false;
    }

    if (!mounted) return;

    setState(() {
      _hasPermissions = granted;
      _isCheckingPermissions = false;
      _permissionMessage = null;
    });

    if (!granted && autoRequest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _requestPermissions();
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (_isRequestingPermissions) return;

    setState(() {
      _isRequestingPermissions = true;
      _permissionMessage = null;
    });

    bool granted = false;
    try {
      granted = await PermissionManager.requestMediaPermissions();
    } catch (_) {
      granted = false;
    }

    if (!mounted) return;

    setState(() {
      _hasPermissions = granted;
      _isRequestingPermissions = false;
      _permissionMessage = granted
          ? null
          : "Permission dialog varala na Settings la permission enable pannunga.";
    });
  }

  Future<void> _openSettings() async {
    await PermissionManager.openPermissionSettings();
    if (!mounted) return;
    await _checkPermissions();
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasPermissions) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Storage permission is required to find media files."),
              if (_permissionMessage != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _permissionMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isRequestingPermissions ? null : _requestPermissions,
                child: _isRequestingPermissions
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Grant Permissions"),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _openSettings,
                child: const Text("Open Settings"),
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
