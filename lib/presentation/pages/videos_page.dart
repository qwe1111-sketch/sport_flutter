import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sport_flutter/domain/repositories/video_repository.dart';
import 'package:sport_flutter/domain/usecases/get_videos.dart';
import 'package:sport_flutter/domain/usecases/favorite_video.dart';
import 'package:sport_flutter/domain/usecases/unfavorite_video.dart';
import 'package:sport_flutter/main.dart'; // Import to get the routeObserver
import 'package:sport_flutter/presentation/bloc/video_bloc.dart';
import 'package:sport_flutter/presentation/bloc/video_event.dart';
import 'package:sport_flutter/presentation/bloc/video_state.dart';
import 'package:sport_flutter/presentation/widgets/video_list_item.dart';
import 'package:sport_flutter/presentation/pages/video_detail_page.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> with RouteAware, TickerProviderStateMixin {
  late final TabController _tabController;
  final List<VideoBloc> _blocs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_blocs.isEmpty) {
      final getVideosUseCase = RepositoryProvider.of<GetVideos>(context, listen: false);
      final favoriteVideoUseCase = RepositoryProvider.of<FavoriteVideo>(context, listen: false);
      final unfavoriteVideoUseCase = RepositoryProvider.of<UnfavoriteVideo>(context, listen: false);
      final cacheManager = RepositoryProvider.of<CacheManager>(context, listen: false);
      
      for (int i = 0; i < 3; i++) {
        _blocs.add(VideoBloc(
          getVideos: getVideosUseCase,
          favoriteVideo: favoriteVideoUseCase,
          unfavoriteVideo: unfavoriteVideoUseCase,
          cacheManager: cacheManager,
        ));
      }
    }

    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _tabController.dispose();
    for (final bloc in _blocs) {
      bloc.close();
    }
    super.dispose();
  }

  @override
  void didPushNext() {
    if (_blocs.isNotEmpty) {
      final activeBloc = _blocs[_tabController.index];
      activeBloc.add(const PausePlayback());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sport Videos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '简单'),
            Tab(text: '中度'),
            Tab(text: '困难'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BlocProvider.value(value: _blocs[0], child: const _VideoList(difficulty: Difficulty.Easy)),
          BlocProvider.value(value: _blocs[1], child: const _VideoList(difficulty: Difficulty.Medium)),
          BlocProvider.value(value: _blocs[2], child: const _VideoList(difficulty: Difficulty.Hard)),
        ],
      ),
    );
  }
}

class _VideoList extends StatefulWidget {
  final Difficulty difficulty;
  const _VideoList({required this.difficulty});

  @override
  State<_VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<_VideoList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<VideoBloc>().add(FetchVideos(widget.difficulty));
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<VideoBloc>().add(FetchVideos(widget.difficulty));
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
    final videoBloc = context.read<VideoBloc>();
    return BlocBuilder<VideoBloc, VideoState>(
      builder: (context, state) {
        if (state is VideoLoaded) {
          if (state.videos.isEmpty) {
            return const Center(child: Text('No videos found.'));
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: state.hasReachedMax ? state.videos.length : state.videos.length + 1,
            itemBuilder: (context, index) {
              if (index >= state.videos.length) {
                return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator()));
              }
              final video = state.videos[index];
              return GestureDetector(
                onTap: () async {
                  videoBloc.add(const PausePlayback());
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => VideoDetailPage(
                        video: video,
                        recommendedVideos: state.videos,
                      ),
                    ),
                  );
                  // If the favorite status changed, refresh the list.
                  if (result == true) {
                    videoBloc.add(FetchVideos(widget.difficulty));
                  }
                },
                child: VideoListItem(video: video, allVideos: state.videos),
              );
            },
          );
        }
        if (state is VideoError) {
          return Center(child: Text('Failed to fetch videos: ${state.message}'));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
