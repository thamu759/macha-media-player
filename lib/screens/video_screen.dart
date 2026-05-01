import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../core/permissions.dart';
import '../providers/media_provider.dart';
import 'video_player_screen.dart';

class VideoScreen extends ConsumerStatefulWidget {
  const VideoScreen({super.key});

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoListAsync = ref.watch(videoListProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _VideoHeader(
              searchQuery: _searchQuery,
              controller: _searchController,
              onSearchChanged: (value) => setState(() => _searchQuery = value),
            ),
            Expanded(
              child: videoListAsync.when(
                data: (videos) {
                  final filteredVideos = videos
                      .where((video) => (video.title ?? "")
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();

                  if (filteredVideos.isEmpty) {
                    return _MediaEmptyState(
                      icon: Icons.video_library_outlined,
                      title: _searchQuery.isEmpty ? "No video access" : "No results",
                      message: _searchQuery.isEmpty
                          ? "Video permission allow pannitu retry pannunga."
                          : "Try a different video title.",
                      onRetry: () => ref.invalidate(videoListProvider),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: filteredVideos.length,
                    itemBuilder: (context, index) {
                      return _VideoCard(video: filteredVideos[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => _MediaEmptyState(
                  icon: Icons.error_outline,
                  title: "Video load aagala",
                  message: '$err',
                  onRetry: () => ref.invalidate(videoListProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoHeader extends StatelessWidget {
  final String searchQuery;
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;

  const _VideoHeader({
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
            "Videos",
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
              hintText: "Search videos",
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

class _VideoCard extends StatelessWidget {
  final AssetEntity video;

  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF171A1F),
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FutureBuilder<Uint8List?>(
                    future: video.thumbnailDataWithSize(
                      const ThumbnailSize(360, 240),
                      quality: 82,
                    ),
                    builder: (context, snapshot) {
                      final data = snapshot.data;
                      if (data == null) {
                        return Container(
                          color: const Color(0xFF222832),
                          child: const Icon(
                            Icons.play_circle_outline,
                            size: 48,
                            color: Color(0xFF00B8A9),
                          ),
                        );
                      }
                      return Image.memory(data, fit: BoxFit.cover);
                    },
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.46),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, size: 32),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.66),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _formatSeconds(video.duration),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                video.title ?? "Untitled video",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, height: 1.2),
              ),
            ),
          ],
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

String _formatSeconds(int seconds) {
  if (seconds <= 0) return "--:--";
  final duration = Duration(seconds: seconds);
  final minutes = duration.inMinutes.remainder(60).toString();
  final paddedSeconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final hours = duration.inHours;
  if (hours > 0) return "$hours:${minutes.padLeft(2, '0')}:$paddedSeconds";
  return "$minutes:$paddedSeconds";
}
