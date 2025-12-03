import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sport_flutter/data/cache/video_cache_manager.dart';
import 'package:sport_flutter/domain/entities/community_post.dart';
import 'package:video_player/video_player.dart';
import 'package:iconsax/iconsax.dart';
import './media_gallery.dart';
import './full_screen_media_viewer.dart';

class PostHeader extends StatefulWidget {
  final CommunityPost post;

  const PostHeader({super.key, required this.post});

  @override
  State<PostHeader> createState() => _PostHeaderState();
}

class _PostHeaderState extends State<PostHeader> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  void _videoPlayerListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.post.videoUrls.isNotEmpty) {
      _initializeVideoPlayerFuture = _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    final url = widget.post.videoUrls.first;
    final fileInfo = await CustomVideoCacheManager().instance.getFileFromCache(url);

    if (fileInfo != null) {
      _controller = VideoPlayerController.file(fileInfo.file);
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      CustomVideoCacheManager().instance.downloadFile(url);
    }

    _controller!.addListener(_videoPlayerListener);
    await _controller!.initialize();
    if (mounted) setState(() {});
    _controller!.setLooping(true);
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoPlayerListener);
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildVideoPlayer() {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (_controller != null && _controller!.value.isInitialized) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: <Widget>[
                // Video Player
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => FullScreenMediaViewer(
                          mediaUrls: widget.post.videoUrls,
                          initialIndex: 0,
                        ),
                      ));
                    },
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  ),
                ),

                // Play/Pause Button
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                    },
                    child: AnimatedOpacity(
                      opacity: _controller!.value.isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Iconsax.play, color: Colors.white, size: 48),
                      ),
                    ),
                  ),
                ),

                // Progress Bar
                if (_controller!.value.isPlaying)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                      padding: const EdgeInsets.all(8.0),
                      colors: VideoProgressColors(
                        playedColor: Theme.of(context).primaryColor,
                        bufferedColor: Colors.white.withOpacity(0.5),
                        backgroundColor: Colors.black.withOpacity(0.25),
                      ),
                    ),
                  ),
              ],
            ),
          );
        } else {
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: widget.post.userAvatarUrl != null && widget.post.userAvatarUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(widget.post.userAvatarUrl!)
                    : null,
                child: widget.post.userAvatarUrl == null || widget.post.userAvatarUrl!.isEmpty
                    ? const Icon(Iconsax.profile, size: 18)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(widget.post.username, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.post.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(widget.post.content, style: Theme.of(context).textTheme.bodyLarge),
          if (widget.post.imageUrls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: MediaGallery(imageUrls: widget.post.imageUrls),
            ),
          if (widget.post.videoUrls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: _buildVideoPlayer(),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
