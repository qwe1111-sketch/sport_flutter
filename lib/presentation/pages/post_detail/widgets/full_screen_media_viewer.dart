import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport_flutter/data/cache/video_cache_manager.dart';
import 'package:video_player/video_player.dart';

class FullScreenMediaViewer extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;

  const FullScreenMediaViewer({
    super.key,
    required this.mediaUrls,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.mediaUrls.length,
        itemBuilder: (context, index) {
          final url = widget.mediaUrls[index];
          final isImage = ['.jpg', '.jpeg', '.png', '.gif'].any((ext) => url.toLowerCase().endsWith(ext));

          if (isImage) {
            return InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.white)),
              ),
            );
          } else {
            return _FullScreenVideoPlayer(videoUrl: url);
          }
        },
      ),
    );
  }
}

class _FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const _FullScreenVideoPlayer({required this.videoUrl});

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _showControls = true;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayerFuture = _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final fileInfo = await CustomVideoCacheManager().instance.getFileFromCache(widget.videoUrl);
    if (fileInfo != null) {
      _controller = VideoPlayerController.file(fileInfo.file);
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      CustomVideoCacheManager().instance.downloadFile(widget.videoUrl);
    }
    await _controller.initialize();
    _controller.play();
    _showAndAutoHideControls();
    if (mounted) setState(() {});
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _showAndAutoHideControls() {
    _controlsTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _showControls = true;
    });
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControlsVisibility() {
    if (!mounted) return;
    setState(() {
      if (_showControls) {
        _showControls = false;
        _controlsTimer?.cancel();
      } else {
        _showAndAutoHideControls();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && _controller.value.isInitialized) {
          return Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: GestureDetector(
                onTap: _toggleControlsVisibility,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    AnimatedOpacity(
                      opacity: _showControls ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Center(
                              child: IconButton(
                                iconSize: 64,
                                icon: Icon(
                                  _controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _controller.value.isPlaying ? _controller.pause() : _controller.play();
                                    _showAndAutoHideControls();
                                  });
                                },
                              ),
                            ),
                            VideoProgressIndicator(
                              _controller,
                              allowScrubbing: true,
                              padding: const EdgeInsets.all(12.0),
                              colors: VideoProgressColors(
                                playedColor: Theme.of(context).primaryColor,
                                bufferedColor: Colors.grey.withOpacity(0.5),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}