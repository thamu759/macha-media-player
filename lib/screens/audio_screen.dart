import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../core/permissions.dart';
import '../providers/media_provider.dart';
import 'now_playing_screen.dart';

class AudioScreen extends ConsumerStatefulWidget {
  const AudioScreen({super.key});

  @override
  ConsumerState<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends ConsumerState<AudioScreen> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioListAsync = ref.watch(audioListProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AudioHeader(
              searchQuery: _searchQuery,
              controller: _searchController,
              onSearchChanged: (value) => setState(() => _searchQuery = value),
            ),
            Expanded(
              child: audioListAsync.when(
                data: (songs) {
                  final filteredSongs = songs
                      .where((song) => song.title
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();

                  if (filteredSongs.isEmpty) {
                    return _MediaEmptyState(
                      icon: Icons.library_music_outlined,
                      title: _searchQuery.isEmpty ? "No audio access" : "No results",
                      message: _searchQuery.isEmpty
                          ? "Music permission allow pannitu retry pannunga."
                          : "Try a different song title.",
                      onRetry: () => ref.invalidate(audioListProvider),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: filteredSongs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final song = filteredSongs[index];
                      return _SongTile(
                        song: song,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NowPlayingScreen(song: song),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => _MediaEmptyState(
                  icon: Icons.error_outline,
                  title: "Audio load aagala",
                  message: '$err',
                  onRetry: () => ref.invalidate(audioListProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioHeader extends StatelessWidget {
  final String searchQuery;
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;

  const _AudioHeader({
    required this.searchQuery,
    required this.controller,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Music",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: "Search audio",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: "Clear",
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.clear();
                        onSearchChanged("");
                      },
                    ),
              filled: true,
              fillColor: const Color(0xFF171A1F),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;

  const _SongTile({
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF171A1F),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  artworkWidth: 54,
                  artworkHeight: 54,
                  artworkFit: BoxFit.cover,
                  nullArtworkWidget: Container(
                    width: 54,
                    height: 54,
                    color: const Color(0xFF222832),
                    child: const Icon(Icons.music_note, color: Color(0xFF00B8A9)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      song.artist?.trim().isNotEmpty == true
                          ? song.artist!
                          : "Unknown artist",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatMillis(song.duration),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.52),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _MediaEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF171A1F),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 34, color: const Color(0xFF00B8A9)),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
            TextButton.icon(
              onPressed: PermissionManager.openPermissionSettings,
              icon: const Icon(Icons.settings),
              label: const Text("Open Settings"),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatMillis(int? milliseconds) {
  if (milliseconds == null || milliseconds <= 0) return "--:--";
  final duration = Duration(milliseconds: milliseconds);
  final minutes = duration.inMinutes.remainder(60).toString();
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final hours = duration.inHours;
  if (hours > 0) return "$hours:${minutes.padLeft(2, '0')}:$seconds";
  return "$minutes:$seconds";
}
