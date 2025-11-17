import 'package:sport_flutter/domain/entities/community_post.dart';

// This is the contract that the data layer must implement.
abstract class CommunityPostRepository {
  Future<List<CommunityPost>> getPosts();
  Future<List<CommunityPost>> getMyPosts(); // New method
  Future<void> createPost(String title, String content, String? imageUrl, String? videoUrl);
  Future<void> deletePost(int postId);
}
