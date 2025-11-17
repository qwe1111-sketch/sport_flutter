import 'package:sport_flutter/domain/entities/post_comment.dart';

abstract class PostCommentRepository {
  Future<List<PostComment>> getPostComments(int postId);
  Future<void> createPostComment(int postId, String content, {int? parentCommentId});
  Future<void> likeComment(int commentId);
  Future<void> dislikeComment(int commentId);
  Future<void> deleteComment(int commentId);
}
