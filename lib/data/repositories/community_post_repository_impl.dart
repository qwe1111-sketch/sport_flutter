import 'package:sport_flutter/data/datasources/community_remote_data_source.dart';
import 'package:sport_flutter/domain/entities/community_post.dart';
import 'package:sport_flutter/domain/repositories/community_post_repository.dart';

class CommunityPostRepositoryImpl implements CommunityPostRepository {
  final CommunityRemoteDataSource remoteDataSource;

  CommunityPostRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CommunityPost>> getPosts() async {
    return await remoteDataSource.getPosts();
  }

  @override
  Future<List<CommunityPost>> getMyPosts() async {
    return await remoteDataSource.getMyPosts();
  }

  @override
  Future<void> createPost(String title, String content, List<String>? imageUrls, List<String>? videoUrls, String? userAvatarUrl) async {
    return await remoteDataSource.createPost(title, content, imageUrls, videoUrls, userAvatarUrl);
  }

  @override
  Future<void> deletePost(int postId) async {
    return await remoteDataSource.deletePost(postId);
  }

  @override
  Future<Map<String, dynamic>> favoritePost(int postId) async {
    return await remoteDataSource.favoritePost(postId);
  }

  @override
  Future<Map<String, dynamic>> dislikePost(int postId) async {
    return await remoteDataSource.dislikePost(postId);
  }

  @override
  Future<Map<String, dynamic>> likePost(int postId) async {
    return await remoteDataSource.likePost(postId);
  }

  @override
  Future<List<CommunityPost>> getFavoritePosts() async {
    return await remoteDataSource.getFavoritePosts();
  }
}
