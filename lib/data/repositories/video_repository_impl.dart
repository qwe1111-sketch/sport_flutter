import 'package:sport_flutter/data/datasources/video_remote_data_source.dart';
import 'package:sport_flutter/domain/entities/video.dart';
import 'package:sport_flutter/domain/repositories/video_repository.dart';

class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;

  VideoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Video>> getVideos({
    required Difficulty difficulty,
    required int page,
  }) async {
    return await remoteDataSource.getVideos(difficulty: difficulty, page: page);
  }

  @override
  Future<void> favoriteVideo(int videoId) async {
    return await remoteDataSource.favoriteVideo(videoId);
  }

  @override
  Future<void> unfavoriteVideo(int videoId) async {
    return await remoteDataSource.unfavoriteVideo(videoId);
  }

  @override
  Future<List<Video>> getFavoriteVideos() async {
    return await remoteDataSource.getFavoriteVideos();
  }
}
