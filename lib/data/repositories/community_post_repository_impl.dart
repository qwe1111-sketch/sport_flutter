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
  Future<void> createPost(String title, String content, String? imageUrl, String? videoUrl) async {
    return await remoteDataSource.createPost(title, content, imageUrl, videoUrl);
  }

  @override
  Future<void> deletePost(int postId) async {
    return await remoteDataSource.deletePost(postId);
  }
}
