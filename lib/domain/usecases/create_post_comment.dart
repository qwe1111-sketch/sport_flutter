import 'package:equatable/equatable.dart';
import 'package:sport_flutter/domain/repositories/post_comment_repository.dart';

class CreatePostComment {
  final PostCommentRepository repository;

  CreatePostComment(this.repository);

  Future<void> call(CreatePostCommentParams params) {
    return repository.createPostComment(params.postId, params.content, parentCommentId: params.parentCommentId);
  }
}

class CreatePostCommentParams extends Equatable {
  final int postId;
  final String content;
  final int? parentCommentId;

  const CreatePostCommentParams({
    required this.postId,
    required this.content,
    this.parentCommentId,
  });

  @override
  List<Object?> get props => [postId, content, parentCommentId];
}
