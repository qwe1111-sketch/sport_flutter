import 'package:equatable/equatable.dart';

class Video extends Equatable {
  final int id;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final String authorName;
  final int viewCount;
  final int likeCount;
  final DateTime createdAt;
  final bool isFavorited; // New field

  const Video({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.authorName,
    required this.viewCount,
    required this.likeCount,
    required this.createdAt,
    this.isFavorited = false, // Default to false
  });

  Video copyWith({
    int? id,
    String? title,
    String? videoUrl,
    String? thumbnailUrl,
    String? authorName,
    int? viewCount,
    int? likeCount,
    DateTime? createdAt,
    bool? isFavorited,
  }) {
    return Video(
      id: id ?? this.id,
      title: title ?? this.title,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      authorName: authorName ?? this.authorName,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }

  @override
  List<Object?> get props => [id, title, videoUrl, thumbnailUrl, authorName, viewCount, likeCount, createdAt, isFavorited];
}
