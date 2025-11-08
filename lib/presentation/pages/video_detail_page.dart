import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sport_flutter/domain/entities/video.dart';
import 'package:video_player/video_player.dart';

class VideoDetailPage extends StatefulWidget {
  final Video video;

  const VideoDetailPage({super.key, required this.video});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late VideoPlayerController _controller;
  bool _isFullScreen = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
          _startHideTimer(); // Start the timer when playback begins
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideControlsTimer?.cancel(); // Cancel the timer to prevent memory leaks
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    }
    super.dispose();
  }

  void _startHideTimer() {
    _hideControlsTimer?.cancel(); // Cancel any existing timer
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleFullScreen() {
    _startHideTimer();
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoPlayer = GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
        if (_showControls) {
          _startHideTimer();
        }
      },
      child: AspectRatio(
        aspectRatio: _controller.value.isInitialized ? _controller.value.aspectRatio : 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_controller.value.isInitialized)
              VideoPlayer(_controller)
            else
              const Center(child: CircularProgressIndicator()),
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _buildControls(context),
            ),
          ],
        ),
      ),
    );

    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: videoPlayer),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.video.title)),
      body: Column(
        children: [
          videoPlayer,
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.comment, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('// TODO: Comments Section'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: IconButton(
            icon: Icon(_controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
            onPressed: () {
              _startHideTimer();
              setState(() {
                _controller.value.isPlaying ? _controller.pause() : _controller.play();
              });
            },
            color: Colors.white,
            iconSize: 60,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black38,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                VideoProgressIndicator(_controller, allowScrubbing: true),
                Row(
                  children: [
                    const SizedBox(width: 8),
                    PopupMenuButton<double>(
                      onSelected: (speed) {
                        _startHideTimer();
                        _controller.setPlaybackSpeed(speed);
                      },
                      itemBuilder: (context) => [
                        for (final speed in [0.5, 1.0, 1.5, 2.0])
                          PopupMenuItem(value: speed, child: Text('${speed}x')),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${_controller.value.playbackSpeed}x',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
                      onPressed: _toggleFullScreen,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
