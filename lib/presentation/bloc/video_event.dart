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

// A single, more powerful event to report visibility changes.
class UpdateVideoVisibility extends VideoEvent {
  final int videoId;
  final double visibilityFraction; // e.g., 0.0 for not visible, 1.0 for fully visible

  const UpdateVideoVisibility(this.videoId, this.visibilityFraction);

  @override
  List<Object> get props => [videoId, visibilityFraction];
}
