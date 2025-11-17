import 'package:sport_flutter/domain/repositories/video_repository.dart';

class FavoriteVideo {
  final VideoRepository repository;

  FavoriteVideo(this.repository);

  Future<void> call(int videoId) {
    return repository.favoriteVideo(videoId);
  }
}
