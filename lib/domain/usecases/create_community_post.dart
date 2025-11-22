import 'package:sport_flutter/domain/repositories/community_post_repository.dart';

class CreateCommunityPost {
  final CommunityPostRepository repository;

  CreateCommunityPost(this.repository);

  Future<void> call({
    required String title,
    required String content,
    List<String>? imageUrls,
    List<String>? videoUrls,
    String? userAvatarUrl,
  }) {
    return repository.createPost(
      title,
      content,
      imageUrls,
      videoUrls,
      userAvatarUrl,
    );
  }
}
