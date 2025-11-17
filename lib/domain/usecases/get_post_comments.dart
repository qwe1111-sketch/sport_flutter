import 'package:sport_flutter/domain/entities/post_comment.dart';
import 'package:sport_flutter/domain/repositories/post_comment_repository.dart';

class GetPostComments {
  final PostCommentRepository repository;

  GetPostComments(this.repository);

  Future<List<PostComment>> call(int postId) async {
    return await repository.getPostComments(postId);
  }
}
