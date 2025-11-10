import 'package:equatable/equatable.dart';

class Video extends Equatable {
  final int id;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final String authorName;
  
  // New fields for dynamic data
  final int viewCount;
  final int likeCount;
  final DateTime createdAt;

  const Video({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.authorName,
    required this.viewCount,
    required this.likeCount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, videoUrl, thumbnailUrl, authorName, viewCount, likeCount, createdAt];
}
