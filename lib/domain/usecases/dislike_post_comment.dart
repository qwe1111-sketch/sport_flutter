import 'package:sport_flutter/domain/repositories/post_comment_repository.dart';

class DislikePostCommentUseCase {
  final PostCommentRepository repository;

  DislikePostCommentUseCase(this.repository);

  Future<void> call(int commentId) {
    return repository.dislikeComment(commentId);
  }
}
