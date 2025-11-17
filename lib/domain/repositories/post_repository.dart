import 'package:sport_flutter/domain/entities/community_post.dart';
import 'package:sport_flutter/domain/entities/post_comment.dart';

abstract class PostRepository {
  Future<List<CommunityPost>> getCommunityPosts();
  Future<void> createCommunityPost(String title, String content, String? imageUrl, String? videoUrl);
  Future<List<PostComment>> getPostComments(int postId);
  Future<void> createPostComment(int postId, String content);
}
