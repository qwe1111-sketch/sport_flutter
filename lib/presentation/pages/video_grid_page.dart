import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sport_flutter/domain/entities/video.dart';
import 'package:sport_flutter/domain/repositories/video_repository.dart';
import 'package:sport_flutter/domain/usecases/favorite_video.dart';
import 'package:sport_flutter/domain/usecases/get_videos.dart';
import 'package:sport_flutter/domain/usecases/unfavorite_video.dart';
import 'package:sport_flutter/presentation/bloc/video_bloc.dart';
import 'package:sport_flutter/presentation/bloc/video_event.dart';
import 'package:sport_flutter/presentation/bloc/video_state.dart';
import 'package:sport_flutter/presentation/pages/video_detail_page.dart';

class VideoGridPage extends StatefulWidget {
  final String title;
  final Difficulty difficulty;

  const VideoGridPage({
    super.key,
    required this.title,
    required this.difficulty,
  });

  @override
  State<VideoGridPage> createState() => _VideoGridPageState();
}

class _VideoGridPageState extends State<VideoGridPage> {
  late final VideoBloc _videoBloc;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final getVideosUseCase = RepositoryProvider.of<GetVideos>(context, listen: false);
    final favoriteVideoUseCase = RepositoryProvider.of<FavoriteVideo>(context, listen: false);
    final unfavoriteVideoUseCase = RepositoryProvider.of<UnfavoriteVideo>(context, listen: false);
    final cacheManager = RepositoryProvider.of<CacheManager>(context, listen: false);

    _videoBloc = VideoBloc(
      getVideos: getVideosUseCase,
      favoriteVideo: favoriteVideoUseCase,
      unfavoriteVideo: unfavoriteVideoUseCase,
      cacheManager: cacheManager,
    )..add(FetchVideos(widget.difficulty));

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _videoBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _videoBloc.add(FetchVideos(widget.difficulty));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: BlocProvider.value(
        value: _videoBloc,
        child: BlocBuilder<VideoBloc, VideoState>(
          builder: (context, state) {
            if (state is VideoLoaded) {
              if (state.videos.isEmpty) {
                return const Center(child: Text('No videos found.'));
              }
              return GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.75,
                ),
                itemCount: state.hasReachedMax ? state.videos.length : state.videos.length + 1,
                itemBuilder: (context, index) {
                  if (index >= state.videos.length) {
                    return const SizedBox.shrink();
                  }
                  final video = state.videos[index];
                  return _GridItem(video: video);
                },
              );
            }
            if (state is VideoError) {
              return Center(child: Text('Failed to fetch videos: ${state.message}'));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _GridItem extends StatelessWidget {
  final Video video;

  const _GridItem({required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoDetailPage(
              video: video,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: video.thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
