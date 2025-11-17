import 'package:sport_flutter/domain/repositories/post_comment_repository.dart';

class DeletePostCommentUseCase {
  final PostCommentRepository repository;

  DeletePostCommentUseCase(this.repository);

  Future<void> call(int commentId) {
    return repository.deleteComment(commentId);
  }
}
