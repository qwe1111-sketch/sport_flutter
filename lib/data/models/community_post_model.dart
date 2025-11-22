import 'package:sport_flutter/domain/entities/community_post.dart';

class CommunityPostModel extends CommunityPost {
  const CommunityPostModel({
    required int id,
    required String username,
    String? userAvatarUrl,
    required String title,
    required String content,
    required DateTime createdAt,
    List<String> imageUrls = const [],
    List<String> videoUrls = const [],
    int commentCount = 0,
    int likeCount = 0,
    List<String>? tags,
  }) : super(
          id: id,
          username: username,
          userAvatarUrl: userAvatarUrl,
          title: title,
          content: content,
          createdAt: createdAt,
          imageUrls: imageUrls,
          videoUrls: videoUrls,
          commentCount: commentCount,
          likeCount: likeCount,
          tags: tags,
        );

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      id: json['id'] as int,
      username: json['username'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      imageUrls: json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : [],
      videoUrls: json['videoUrls'] != null ? List<String>.from(json['videoUrls']) : [],
      commentCount: json['commentCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'userAvatarUrl': userAvatarUrl,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'imageUrls': imageUrls,
      'videoUrls': videoUrls,
      'commentCount': commentCount,
      'likeCount': likeCount,
      'tags': tags,
    };
  }
}
