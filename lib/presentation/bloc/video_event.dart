import 'package:equatable/equatable.dart';
import 'package:sport_flutter/domain/repositories/video_repository.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}

class FetchVideos extends VideoEvent {
  final Difficulty difficulty;

  const FetchVideos(this.difficulty);

  @override
  List<Object> get props => [difficulty];
}

class UpdateVideoVisibility extends VideoEvent {
  final int videoId;
  final double visibilityFraction;

  const UpdateVideoVisibility(this.videoId, this.visibilityFraction);

  @override
  List<Object> get props => [videoId, visibilityFraction];
}

// New event to explicitly pause all video playback on the home screen
class PausePlayback extends VideoEvent {
  const PausePlayback();
}
