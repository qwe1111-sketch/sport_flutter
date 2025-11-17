import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sport_flutter/domain/entities/community_post.dart';
import 'package:video_player/video_player.dart';

class PostHeader extends StatefulWidget {
  final CommunityPost post;
  const PostHeader({super.key, required this.post});

  @override
  State<PostHeader> createState() => _PostHeaderState();
}

class _PostHeaderState extends State<PostHeader> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.post.videoUrl != null && widget.post.videoUrl!.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.post.videoUrl!));
      _initializeVideoPlayerFuture = _controller!.initialize()..then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAuthorInfo(context),
          const SizedBox(height: 24),
          _buildPostContent(context),
          const SizedBox(height: 24),
          _buildMediaContent(),
          const Divider(height: 48),
        ],
      ),
    );
  }
  
  Widget _buildVideoPlayer() {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (_controller != null && _controller!.value.isInitialized) {
          return AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: GestureDetector(
              onTap: () => setState(() => _controller!.value.isPlaying ? _controller!.pause() : _controller!.play()),
              child: Stack(alignment: Alignment.center, children: <Widget>[ VideoPlayer(_controller!), if (!_controller!.value.isPlaying) Container(padding: const EdgeInsets.all(8.0), decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle), child: const Icon(Icons.play_arrow, color: Colors.white, size: 60))]),
            ),
          );
        } else {
          return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }

  Widget _buildAuthorInfo(BuildContext context) {
    return Row(children: [const CircleAvatar(radius: 20, child: Icon(Icons.person)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.post.username, style: Theme.of(context).textTheme.titleMedium), Text(DateFormat('yyyy-MM-dd HH:mm').format(widget.post.createdAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey))])]);
  }

  Widget _buildPostContent(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.post.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 16), Text(widget.post.content, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5))]);
  }

  Widget _buildMediaContent() {
    if (widget.post.imageUrl != null) return ClipRRect(borderRadius: BorderRadius.circular(12.0), child: Image.network(widget.post.imageUrl!, fit: BoxFit.cover, width: double.infinity));
    if (widget.post.videoUrl != null) return ClipRRect(borderRadius: BorderRadius.circular(12.0), child: _buildVideoPlayer());
    return const SizedBox.shrink();
  }
}
