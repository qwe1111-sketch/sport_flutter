import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sport_flutter/data/cache/video_cache_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:iconsax/iconsax.dart';

class CachedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool loop;
  final bool showControls;

  const CachedVideoPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
    this.loop = false,
    this.showControls = true,
  });

  @override
  State<CachedVideoPlayer> createState() => _CachedVideoPlayerState();
}

class _CachedVideoPlayerState extends State<CachedVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final fileInfo = await CustomVideoCacheManager().instance.getFileFromCache(widget.videoUrl);
    
    VideoPlayerController controller;
    if (fileInfo != null) {
      controller = VideoPlayerController.file(fileInfo.file);
    } else {
      controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      // Download file to cache for next time
      CustomVideoCacheManager().instance.downloadFile(widget.videoUrl);
    }

    _controller = controller;
    
    // Add listener to rebuild the widget on player state changes (play, pause, etc.)
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    await controller.initialize();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (widget.autoPlay) {
          controller.play();
        }
      });

      if(widget.loop) {
        controller.setLooping(true);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (visibilityInfo) {
        final visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (mounted && _controller != null) {
          // Auto-pause if video is less than 50% visible
          if (visiblePercentage < 50 && _controller!.value.isPlaying) {
            _controller!.pause();
          }
        }
      },
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: GestureDetector(
          onTap: () {
            if (!_controller!.value.isInitialized) return;
            if (_controller!.value.isPlaying) {
              _controller!.pause();
            } else {
              _controller!.play();
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller!),
              if (widget.showControls && !_controller!.value.isPlaying)
                _buildPlayIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayIcon() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: const Icon(Iconsax.play, color: Colors.white, size: 48),
    );
  }
}
