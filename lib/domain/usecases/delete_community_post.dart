import 'package:sport_flutter/domain/repositories/community_post_repository.dart';

class DeleteCommunityPost {
  final CommunityPostRepository repository;

  DeleteCommunityPost(this.repository);

  Future<void> call(int postId) {
    return repository.deletePost(postId);
  }
}
