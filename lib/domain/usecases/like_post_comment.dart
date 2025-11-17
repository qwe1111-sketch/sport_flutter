import 'package:sport_flutter/domain/repositories/post_comment_repository.dart';

class LikePostCommentUseCase {
  final PostCommentRepository repository;

  LikePostCommentUseCase(this.repository);

  Future<void> call(int commentId) {
    return repository.likeComment(commentId);
  }
}
