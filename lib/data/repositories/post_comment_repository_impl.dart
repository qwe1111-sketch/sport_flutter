import 'package:sport_flutter/domain/entities/post_comment.dart';
import 'package:sport_flutter/domain/repositories/post_comment_repository.dart';
import 'package:sport_flutter/data/datasources/post_comment_remote_data_source.dart';
import 'package:sport_flutter/data/models/post_comment_model.dart';

class PostCommentRepositoryImpl implements PostCommentRepository {
  final PostCommentRemoteDataSource remoteDataSource;

  PostCommentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PostComment>> getPostComments(int postId) async {
    final commentModels = await remoteDataSource.getComments(postId);
    // This conversion is crucial. A List<PostCommentModel> is not a List<PostComment>.
    // We must explicitly map the models to entities.
    return commentModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> createPostComment(int postId, String content, {int? parentCommentId}) async {
    await remoteDataSource.createComment(postId, content, parentCommentId: parentCommentId);
  }

  @override
  Future<void> likeComment(int commentId) async {
    await remoteDataSource.voteOnComment(commentId, 'like');
  }

  @override
  Future<void> dislikeComment(int commentId) async {
    await remoteDataSource.voteOnComment(commentId, 'dislike');
  }

  @override
  Future<void> deleteComment(int commentId) async {
    await remoteDataSource.deleteComment(commentId);
  }
}
