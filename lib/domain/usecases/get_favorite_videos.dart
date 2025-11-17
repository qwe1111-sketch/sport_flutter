import 'package:sport_flutter/domain/entities/video.dart';
import 'package:sport_flutter/domain/repositories/video_repository.dart';

class GetFavoriteVideos {
  final VideoRepository repository;

  GetFavoriteVideos(this.repository);

  Future<List<Video>> call() {
    return repository.getFavoriteVideos();
  }
}
