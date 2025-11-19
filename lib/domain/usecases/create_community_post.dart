import 'package:sport_flutter/domain/repositories/community_post_repository.dart';

class CreateCommunityPost {
  final CommunityPostRepository repository;

  CreateCommunityPost(this.repository);

  Future<void> call({
    required String title,
    required String content,
    String? imageUrl,
    String? videoUrl,
    String? userAvatarUrl,
  }) {
    // This use case now correctly calls the repository with positional arguments
    // and returns a Future<void> to match the repository's contract.
    return repository.createPost(
      title,
      content,
      imageUrl,
      videoUrl,
      userAvatarUrl,
    );
  }
}
