import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sport_flutter/domain/entities/video.dart';
import 'package:sport_flutter/domain/repositories/video_repository.dart';
import 'package:sport_flutter/domain/usecases/favorite_video.dart';
import 'package:sport_flutter/domain/usecases/get_videos.dart';
import 'package:sport_flutter/domain/usecases/unfavorite_video.dart';
import 'package:sport_flutter/l10n/app_localizations.dart';
import 'package:sport_flutter/main.dart'; // For routeObserver
import 'package:sport_flutter/presentation/bloc/recommended_video_bloc.dart';
import 'package:sport_flutter/presentation/bloc/video_bloc.dart';
import 'package:sport_flutter/presentation/bloc/video_event.dart';
import 'package:sport_flutter/presentation/bloc/video_state.dart';
import 'package:sport_flutter/presentation/pages/video_detail_page.dart';
import 'package:sport_flutter/presentation/pages/video_grid_page.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> with RouteAware {
  late final List<VideoBloc> _videoBlocs;
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _initializeBlocs();
      _didInit = true;
    }
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  void _initializeBlocs() {
    final videoRepository = RepositoryProvider.of<VideoRepository>(context);
    final getVideosUseCase = GetVideos(videoRepository);
    final favoriteVideoUseCase = FavoriteVideo(videoRepository);
    final unfavoriteVideoUseCase = UnfavoriteVideo(videoRepository);
    final cacheManager = RepositoryProvider.of<CacheManager>(context);

    _videoBlocs = List.generate(3, (i) {
      final bloc = VideoBloc(
        getVideos: getVideosUseCase,
        favoriteVideo: favoriteVideoUseCase,
        unfavoriteVideo: unfavoriteVideoUseCase,
        cacheManager: cacheManager,
      );
      bloc.add(FetchVideos(Difficulty.values[i]));
      return bloc;
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    for (final bloc in _videoBlocs) {
      bloc.close();
    }
    super.dispose();
  }

  @override
  void didPushNext() {
    for (final bloc in _videoBlocs) {
      bloc.add(const PausePlayback());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sportVideos),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_didInit) const _VideoCarousel(),
            const SizedBox(height: 24),
            if (_didInit)
              ...[
                _VideoSection(title: l10n.easy, difficulty: Difficulty.Easy, bloc: _videoBlocs[0]),
                _VideoSection(title: l10n.medium, difficulty: Difficulty.Medium, bloc: _videoBlocs[1]),
                _VideoSection(title: l10n.hard, difficulty: Difficulty.Hard, bloc: _videoBlocs[2]),
              ]
          ],
        ),
      ),
    );
  }
}

class _VideoCarousel extends StatefulWidget {
  const _VideoCarousel();

  @override
  State<_VideoCarousel> createState() => _VideoCarouselState();
}

class _VideoCarouselState extends State<_VideoCarousel> {
  late final PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1000);
  }

  void _startAutoScroll(int itemCount) {
    if (itemCount == 0 || (_timer != null && _timer!.isActive)) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_pageController.hasClients) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecommendedVideoBloc, RecommendedVideoState>(
      builder: (context, state) {
        if (state is RecommendedVideoLoaded) {
          final recommendedVideos = state.videos;
          if (recommendedVideos.isEmpty) {
            return const SizedBox.shrink();
          }
          _startAutoScroll(recommendedVideos.length);
          return SizedBox(
            height: 240, // Increased height
            child: PageView.builder(
              controller: _pageController,
              itemBuilder: (context, index) {
                final video = recommendedVideos[index % recommendedVideos.length];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VideoDetailPage(video: video),
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: video.thumbnailUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error_outline, color: Colors.grey),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withAlpha((255 * 0.6).round()), Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Text(
                          video.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _VideoSection extends StatelessWidget {
  final String title;
  final Difficulty difficulty;
  final VideoBloc bloc;

  const _VideoSection({
    required this.title,
    required this.difficulty,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => VideoGridPage(
                title: title,
                difficulty: difficulty,
              ),
            )),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 180,
            child: BlocBuilder<VideoBloc, VideoState>(
              builder: (context, state) {
                if (state is VideoLoaded) {
                  if (state.videos.isEmpty) {
                    return const Center(child: Text('No videos found.'));
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.videos.length,
                    itemBuilder: (context, index) {
                      return _VideoThumbnailCard(video: state.videos[index]);
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
        ],
      ),
    );
  }
}

class _VideoThumbnailCard extends StatelessWidget {
  final Video video;

  const _VideoThumbnailCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoDetailPage(video: video),
        ),
      ),
      child: SizedBox(
        width: 150,
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(Icons.error_outline, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Container(
                height: 24,
                padding: const EdgeInsets.only(top: 4.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  video.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
