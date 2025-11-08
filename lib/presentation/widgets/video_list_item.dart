import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sport_flutter/domain/entities/video.dart';
import 'package:sport_flutter/presentation/bloc/video_bloc.dart';
import 'package:sport_flutter/presentation/bloc/video_event.dart';
import 'package:sport_flutter/presentation/bloc/video_state.dart';
import 'package:sport_flutter/presentation/pages/video_detail_page.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoListItem extends StatefulWidget {
  final Video video;

  const VideoListItem({super.key, required this.video});

  @override
  State<VideoListItem> createState() => _VideoListItemState();
}

class _VideoListItemState extends State<VideoListItem> {
  VideoPlayerController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeAndPlay() async {
    if (_controller != null) {
      _controller!.play();
      return;
    }

    final cacheManager = RepositoryProvider.of<CacheManager>(context);
    final fileInfo = await cacheManager.getFileFromCache(widget.video.videoUrl) ??
        await cacheManager.downloadFile(widget.video.videoUrl);

    if (mounted) {
      _controller = VideoPlayerController.file(fileInfo.file)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _controller!.play();
            _controller!.setLooping(true);
          }
        });
    }
  }

  void _disposePlayer() {
    if (_controller != null) {
      _controller!.dispose();
      _controller = null;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // On tap, navigate to the detail page
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => VideoDetailPage(video: widget.video),
        ));
      },
      child: BlocListener<VideoBloc, VideoState>(
        listener: (context, state) {
          if (state is VideoLoaded) {
            final bool isMyTurnToPlay = state.activeVideoId == widget.video.id;
            if (isMyTurnToPlay && _controller == null) {
              _initializeAndPlay();
            } else if (!isMyTurnToPlay && _controller != null) {
              _disposePlayer();
            }
          }
        },
        child: VisibilityDetector(
          key: Key(widget.video.id.toString()),
          onVisibilityChanged: (visibilityInfo) {
            if (mounted) {
              context.read<VideoBloc>().add(UpdateVideoVisibility(
                    widget.video.id,
                    visibilityInfo.visibleFraction,
                  ));
            }
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_controller != null && _controller!.value.isInitialized)
                        VideoPlayer(_controller!)
                      else
                        CachedNetworkImage(
                          imageUrl: widget.video.thumbnailUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      if (_controller == null || !_controller!.value.isPlaying)
                        const Icon(Icons.play_arrow, size: 60, color: Colors.white70),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.video.title, style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Text(widget.video.authorName, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
