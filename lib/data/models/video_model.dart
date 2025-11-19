import 'package:sport_flutter/domain/entities/video.dart';

class VideoModel extends Video {
  const VideoModel({
    required super.id,
    required super.title,
    required super.videoUrl,
    required super.thumbnailUrl,
    required super.authorName,
    super.userAvatarUrl,
    required super.viewCount,
    required super.likeCount,
    required super.createdAt,
    required super.isFavorited,
  });

  // This factory constructor is now updated to correctly parse the isFavorited field.
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Untitled Video',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      authorName: json['author_name'] ?? 'Unknown Author',
      userAvatarUrl: json['userAvatarUrl'],
      viewCount: json['view_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      isFavorited: json['isFavorited'] ?? false, // Correctly parse the field
    );
  }
}
