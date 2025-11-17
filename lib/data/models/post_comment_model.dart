import 'package:sport_flutter/domain/entities/post_comment.dart';

// The Model is responsible for parsing JSON and creating a data object.
// It is separate from the domain Entity.
class PostCommentModel {
  final int id;
  final int? parentCommentId;
  final String content;
  final String username;
  final int likeCount;
  final int dislikeCount;
  final DateTime createdAt;
  final int replyCount;
  final List<PostCommentModel> replies;
  final String? userVote;

  const PostCommentModel({
    required this.id,
    this.parentCommentId,
    required this.content,
    required this.username,
    required this.likeCount,
    required this.dislikeCount,
    required this.createdAt,
    required this.replyCount,
    this.replies = const [],
    this.userVote,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    return PostCommentModel(
      id: json['id'] as int,
      parentCommentId: json['parentCommentId'] as int?,
      content: json['content'] as String,
      username: json['username'] as String,
      likeCount: json['likeCount'] as int? ?? 0,
      dislikeCount: json['dislikeCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      replyCount: json['replyCount'] as int? ?? 0,
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((replyJson) => PostCommentModel.fromJson(replyJson as Map<String, dynamic>))
          .toList(),
      userVote: json['userVote'] as String?,
    );
  }

  // Converts this data-layer Model to a domain-layer Entity.
  PostComment toEntity() {
    return PostComment(
      id: id,
      parentCommentId: parentCommentId,
      content: content,
      username: username,
      likeCount: likeCount,
      dislikeCount: dislikeCount,
      createdAt: createdAt,
      replyCount: replyCount,
      userVote: userVote,
      // Recursively convert the replies from Model to Entity.
      replies: replies.map((model) => model.toEntity()).toList(),
    );
  }
}
