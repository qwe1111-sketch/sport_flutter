import 'package:sport_flutter/domain/entities/community_post.dart';

// This is the contract that the data layer must implement.
abstract class CommunityPostRepository {
  Future<List<CommunityPost>> getPosts();
  Future<List<CommunityPost>> getMyPosts(); // New method
  Future<void> createPost(String title, String content, List<String>? imageUrls, List<String>? videoUrls, String? userAvatarUrl);
  Future<void> deletePost(int postId);
  Future<Map<String, dynamic>> favoritePost(int postId);
  Future<Map<String, dynamic>> dislikePost(int postId);
  Future<Map<String, dynamic>> likePost(int postId);
  Future<List<CommunityPost>> getFavoritePosts();
}
