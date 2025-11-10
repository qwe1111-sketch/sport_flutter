import 'package:sport_flutter/domain/entities/video.dart';

class VideoModel extends Video {
  const VideoModel({
    required super.id,
    required super.title,
    required super.videoUrl,
    required super.thumbnailUrl,
    required super.authorName,
    required super.viewCount,
    required super.likeCount,
    required super.createdAt,
  });

  // This factory constructor is now fully robust against missing or null JSON fields.
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'];
    final authorName = (author != null && author['username'] != null) 
                       ? author['username'] 
                       : 'Unknown Author';

    return VideoModel(
      id: json['id'] ?? 0, // Default to 0 if ID is null
      title: json['title'] ?? 'Untitled Video',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      authorName: authorName,
      viewCount: json['view_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}
