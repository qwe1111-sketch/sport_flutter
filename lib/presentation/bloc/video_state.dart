import 'package:equatable/equatable.dart';
import 'package:sport_flutter/domain/entities/video.dart';

class VideoState extends Equatable {
  const VideoState();

  @override
  List<Object?> get props => [];
}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoLoaded extends VideoState {
  final List<Video> videos;
  final bool hasReachedMax;
  final int? activeVideoId; // The ID of the video that is allowed to play

  const VideoLoaded({
    required this.videos,
    required this.hasReachedMax,
    this.activeVideoId,
  });

  // When the state is updated, we can create a copy with new values
  VideoLoaded copyWith({
    List<Video>? videos,
    bool? hasReachedMax,
    int? activeVideoId,
  }) {
    return VideoLoaded(
      videos: videos ?? this.videos,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      activeVideoId: activeVideoId ?? this.activeVideoId,
    );
  }

  @override
  List<Object?> get props => [videos, hasReachedMax, activeVideoId];
}

class VideoError extends VideoState {
  final String message;

  const VideoError(this.message);

  @override
  List<Object> get props => [message];
}
