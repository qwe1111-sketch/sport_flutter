
import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_flutter/data/datasources/auth_remote_data_source.dart';
import 'package:sport_flutter/data/models/video_model.dart';
import 'package:sport_flutter/domain/entities/video.dart';
import 'package:sport_flutter/domain/usecases/favorite_video.dart';
import 'package:sport_flutter/domain/usecases/unfavorite_video.dart';
import 'package:sport_flutter/presentation/bloc/comment_bloc.dart';
import 'package:sport_flutter/presentation/widgets/comment_widgets.dart';
import 'package:video_player/video_player.dart';

class VideoDetailPage extends StatefulWidget {
  final Video video;
  final List<Video> recommendedVideos;

  const VideoDetailPage({
    super.key,
    required this.video,
    this.recommendedVideos = const [],
  });

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late VideoPlayerController _controller;
  late Video _currentVideo;
  late final CommentBloc _commentBloc;

  bool _isFullScreen = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _isFavorited = false;
  bool _didFavoriteChange = false;
  bool _viewRecorded = false;
  bool _isInteracting = false;

  final String _apiBaseUrl = AuthRemoteDataSourceImpl.getBaseApiUrl();

  @override
  void initState() {
    super.initState();
    _currentVideo = widget.video;
    _isFavorited = widget.video.isFavorited;
    _commentBloc = CommentBloc();
    _fetchInitialStatus();
    _initializePlayer(_currentVideo.videoUrl);
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    _hideControlsTimer?.cancel();
    _commentBloc.close();
    if (_isFullScreen) {
      _exitFullScreen();
    }
    super.dispose();
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token'
    };
  }

  void _initializePlayer(String url) {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _controller.play();
        _startHideTimer();
      })
      ..addListener(_videoListener);
  }

  Future<void> _changeVideo(Video newVideo) async {
    if (!mounted) return;

    await _controller.dispose();
    setState(() {
      _currentVideo = newVideo;
      _isFavorited = newVideo.isFavorited;
      _viewRecorded = false;
      _isLiked = false;
      _isDisliked = false;
    });

    await _fetchInitialStatus();
    _initializePlayer(newVideo.videoUrl);
    _commentBloc.add(FetchComments(newVideo.id));
  }

  Future<void> _fetchInitialStatus() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/videos/${_currentVideo.id}/status'),
        headers: headers,
      );
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        final video = VideoModel.fromJson(data);
        final isLiked = data['isLikedByUser'] ?? false;
        final isDisliked = data['isDislikedByUser'] ?? false;

        setState(() {
          _currentVideo = video;
          _isLiked = isLiked;
          _isDisliked = isDisliked;
          _isFavorited = video.isFavorited;
        });
      }
    } catch (_) {
      // Handle error
    }
  }

  void _videoListener() {
    if (!_viewRecorded &&
        !_controller.value.hasError &&
        _controller.value.position >= _controller.value.duration) {
      _recordView();
      _viewRecorded = true;
    }
  }

  Future<void> _recordView() async {
    try {
      final headers = await _getAuthHeaders();
      await http.post(
        Uri.parse('$_apiBaseUrl/videos/${_currentVideo.id}/view'),
        headers: headers,
      );
    } catch (_) {
      // Handle error
    }
  }

  Future<void> _toggleLike() async => _performVoteAction('like');
  Future<void> _toggleDislike() async => _performVoteAction('dislike');

  Future<void> _toggleFavorite() async {
    final isCurrentlyFavorited = _isFavorited;
    setState(() {
      _isFavorited = !isCurrentlyFavorited;
      _didFavoriteChange = true;
    });

    try {
      if (isCurrentlyFavorited) {
        await context.read<UnfavoriteVideo>()(_currentVideo.id);
      } else {
        await context.read<FavoriteVideo>()(_currentVideo.id);
      }
    } catch (e) {
      setState(() {
        _isFavorited = isCurrentlyFavorited;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  Future<void> _performVoteAction(String action) async {
    if (_isInteracting) return;
    setState(() => _isInteracting = true);

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/videos/${_currentVideo.id}/$action'),
        headers: headers,
      );
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        final video = VideoModel.fromJson(data);
        final isLiked = data['isLikedByUser'] ?? false;
        final isDisliked = data['isDislikedByUser'] ?? false;

        setState(() {
          _currentVideo = video;
          _isLiked = isLiked;
          _isDisliked = isDisliked;
        });
      }
    } catch (_) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isInteracting = false);
    }
  }

  void _startHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showControls = false);
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
        _exitFullScreen();
      }
    });
  }

  void _exitFullScreen() {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    // Conditional layout based on fullscreen mode
    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: _buildVideoPlayer(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_currentVideo.title)),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.of(context).pop(_didFavoriteChange);
        },
        child: Column(
          children: [
            _buildVideoPlayer(),
            Expanded(child: _buildMetaAndCommentsSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: () {
        setState(() => _showControls = !_showControls);
        if (_showControls) _startHideTimer();
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
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMetaAndCommentsSection() {
    return BlocProvider.value(
      value: _commentBloc,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(tabs: [Tab(text: '简介'), Tab(text: '评论')]),
            Expanded(
              child: TabBarView(
                children: [
                  _buildIntroPanel(),
                  CommentSection(videoId: _currentVideo.id),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIntroPanel() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAuthorInfo(),
                const SizedBox(height: 12),
                Text(_currentVideo.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  '${_formatNumber(_currentVideo.viewCount)}次观看 - ${_formatDate(_currentVideo.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                _buildActionButtons(),
                const Divider(height: 32),
                const Text('接下来播放', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (c, i) {
              final v = widget.recommendedVideos[i];
              if (v.id == _currentVideo.id) return const SizedBox.shrink();
              return _buildRecommendedItem(c, v);
            },
            childCount: widget.recommendedVideos.length,
          ),
        )
      ],
    );
  }

  Widget _buildAuthorInfo() {
      return Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(child: Text(_currentVideo.authorName, style: Theme.of(context).textTheme.titleMedium)),
          ElevatedButton(onPressed: () {}, child: const Text('+ 关注')),
        ],
      );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
          label: _formatNumber(_currentVideo.likeCount),
          onPressed: _toggleLike,
        ),
        _buildActionButton(
          icon: _isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
          label: '不喜欢',
          onPressed: _toggleDislike,
        ),
        _buildActionButton(
          icon: _isFavorited ? Icons.star : Icons.star_border,
          label: '收藏',
          onPressed: _toggleFavorite,
        ),
        _buildActionButton(icon: Icons.share_outlined, label: '分享'),
      ],
    );
  }

  Widget _buildRecommendedItem(BuildContext context, Video video) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () => _changeVideo(video),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (c, u, e) => const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video.authorName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: _isInteracting ? Colors.grey : Theme.of(context).iconTheme.color,
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
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
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
              setState(() {});
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
                    _buildSpeedMenu(),
                    const Spacer(),
                    IconButton(
                      icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
                      onPressed: _toggleFullScreen,
                      color: Colors.white,
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }

    Widget _buildSpeedMenu() {
      return PopupMenuButton<double>(
        onSelected: (speed) {
          _startHideTimer();
          _controller.setPlaybackSpeed(speed);
        },
        itemBuilder: (context) => [0.5, 1.0, 1.5, 2.0]
            .map((speed) => PopupMenuItem(value: speed, child: Text('${speed}x')))
            .toList(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${_controller.value.playbackSpeed}x',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

  String _formatNumber(int n) => (n >= 10000) ? '${(n / 10000).toStringAsFixed(1)}万' : n.toString();

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 1) return '${diff.inDays}天前';
    if (diff.inHours > 1) return '${diff.inHours}小时前';
    return '刚刚';
  }
}
