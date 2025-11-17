import 'package:sport_flutter/domain/entities/community_post.dart';
import 'package:sport_flutter/domain/repositories/community_post_repository.dart';

class GetMyPosts {
  final CommunityPostRepository repository;

  GetMyPosts(this.repository);

  Future<List<CommunityPost>> call() {
    return repository.getMyPosts();
  }
}
