import 'package:sport_flutter/domain/repositories/video_repository.dart';

class UnfavoriteVideo {
  final VideoRepository repository;

  UnfavoriteVideo(this.repository);

  Future<void> call(int videoId) {
    return repository.unfavoriteVideo(videoId);
  }
}
