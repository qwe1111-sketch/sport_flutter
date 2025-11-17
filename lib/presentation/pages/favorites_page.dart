import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sport_flutter/presentation/bloc/favorites_bloc.dart';
import 'package:sport_flutter/presentation/pages/video_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesBloc = BlocProvider.of<FavoritesBloc>(context);
    favoritesBloc.add(FetchFavorites());

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FavoritesLoaded) {
            if (state.videos.isEmpty) {
              return const Center(child: Text('您还没有收藏任何视频。'));
            }
            return ListView.builder(
              itemCount: state.videos.length,
              itemBuilder: (context, index) {
                final video = state.videos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Image.network(video.thumbnailUrl, width: 100, fit: BoxFit.cover),
                    title: Text(video.title),
                    subtitle: Text(video.authorName),
                    onTap: () async {
                      final result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => VideoDetailPage(video: video, recommendedVideos: state.videos),
                        ),
                      );
                      // If the favorite status changed, refresh the list.
                      if (result == true) {
                        favoritesBloc.add(FetchFavorites());
                      }
                    },
                  ),
                );
              },
            );
          } else if (state is FavoritesError) {
            return Center(child: Text('加载失败: ${state.message}'));
          } else {
            return const Center(child: Text('点击加载收藏'));
          }
        },
      ),
    );
  }
}
