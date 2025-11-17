import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sport_flutter/presentation/bloc/my_posts_bloc.dart';
import 'package:sport_flutter/presentation/pages/post_detail_page.dart'; // New

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger the fetch event as soon as the page is built
    context.read<MyPostsBloc>().add(FetchMyPosts());

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的帖子'),
      ),
      body: BlocBuilder<MyPostsBloc, MyPostsState>(
        builder: (context, state) {
          if (state is MyPostsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MyPostsLoaded) {
            if (state.posts.isEmpty) {
              return const Center(child: Text('您还没有发布任何帖子。'));
            }
            return ListView.builder(
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                final post = state.posts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(post.title),
                    subtitle: Text(
                      post.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () { // New: Add onTap event
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PostDetailPage(post: post),
                      ));
                    },
                  ),
                );
              },
            );
          } else if (state is MyPostsError) {
            return Center(child: Text('加载失败: ${state.message}'));
          } else {
            return const Center(child: Text('点击加载帖子')); // Should not happen with auto-fetch
          }
        },
      ),
    );
  }
}
