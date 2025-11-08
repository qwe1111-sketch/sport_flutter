import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'; // Import the cache manager
import 'package:sport_flutter/domain/repositories/video_repository.dart';
import 'package:sport_flutter/domain/usecases/get_videos.dart';
import 'package:sport_flutter/presentation/bloc/video_bloc.dart';
import 'package:sport_flutter/presentation/bloc/video_event.dart';
import 'package:sport_flutter/presentation/bloc/video_state.dart';
import 'package:sport_flutter/presentation/widgets/video_list_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve dependencies from the context
    final getVideosUseCase = RepositoryProvider.of<GetVideos>(context);
    final cacheManager = RepositoryProvider.of<CacheManager>(context);

    return DefaultTabController(
      length: 3, // For Easy, Medium, Hard
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sport Videos'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '简单'),
              Tab(text: '中度'),
              Tab(text: '困难'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Provide a new, independent VideoBloc for each tab
            BlocProvider(
              create: (context) => VideoBloc(
                getVideos: getVideosUseCase,
                cacheManager: cacheManager, // Pass the cache manager
              ),
              child: const _VideoList(difficulty: Difficulty.Easy),
            ),
            BlocProvider(
              create: (context) => VideoBloc(
                getVideos: getVideosUseCase,
                cacheManager: cacheManager, // Pass the cache manager
              ),
              child: const _VideoList(difficulty: Difficulty.Medium),
            ),
            BlocProvider(
              create: (context) => VideoBloc(
                getVideos: getVideosUseCase,
                cacheManager: cacheManager, // Pass the cache manager
              ),
              child: const _VideoList(difficulty: Difficulty.Hard),
            ),
          ],
        ),
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
    // Fetch the first batch of videos
    context.read<VideoBloc>().add(FetchVideos(widget.difficulty));

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
    return BlocBuilder<VideoBloc, VideoState>(
      builder: (context, state) {
        switch (state) {
          case VideoInitial():
          case VideoLoading():
            return const Center(child: CircularProgressIndicator());

          case VideoLoaded():
            if (state.videos.isEmpty) {
              return const Center(child: Text('No videos found for this category.'));
            }
            return ListView.builder(
              controller: _scrollController,
              itemCount: state.hasReachedMax ? state.videos.length : state.videos.length + 1,
              itemBuilder: (context, index) {
                return index >= state.videos.length
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : VideoListItem(video: state.videos[index]);
              },
            );

          case VideoError():
            return Center(child: Text('Failed to fetch videos: ${state.message}'));

          default:
            return const Center(child: Text('Something went wrong.'));
        }
      },
    );
  }
}
