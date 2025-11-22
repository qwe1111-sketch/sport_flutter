import 'package:equatable/equatable.dart';

class CommunityPost extends Equatable {
  final int id;
  final String username;
  final String? userAvatarUrl;
  final String title;
  final String content;
  final DateTime createdAt;
  final List<String> imageUrls; // Changed from single URL
  final List<String> videoUrls; // Changed from single URL
  final int commentCount;
  final int likeCount;
  final int dislikeCount; // Added this field
  final List<String>? tags;

  const CommunityPost({
    required this.id,
    required this.username,
    this.userAvatarUrl,
    required this.title,
    required this.content,
    required this.createdAt,
    this.imageUrls = const [], // Default to empty list
    this.videoUrls = const [], // Default to empty list
    this.commentCount = 0,
    this.likeCount = 0,
    this.dislikeCount = 0, // Default to 0
    this.tags,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        userAvatarUrl,
        title,
        content,
        createdAt,
        imageUrls,
        videoUrls,
        commentCount,
        likeCount,
        dislikeCount, // Added to props
        tags,
      ];
}
