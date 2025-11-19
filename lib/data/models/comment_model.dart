import 'package:sport_flutter/domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.content,
    required super.username,
    super.userAvatarUrl,
    required super.likeCount,
    required super.dislikeCount,
    required super.createdAt,
    required super.replyCount,
    super.replies = const [],
    super.userVote,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    var repliesFromJson = json['replies'] as List? ?? [];
    List<Comment> replyList = repliesFromJson.map((i) => CommentModel.fromJson(i)).toList();

    var createdAtString = json['created_at'] as String? ?? '';
    if (createdAtString.endsWith('ZZ')) {
      createdAtString = createdAtString.substring(0, createdAtString.length - 1);
    }

    return CommentModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      username: json['username'] ?? 'Unknown User',
      userAvatarUrl: json['userAvatarUrl'],
      likeCount: json['like_count'] ?? 0,
      dislikeCount: json['dislike_count'] ?? 0,
      createdAt: createdAtString.isNotEmpty ? DateTime.parse(createdAtString) : DateTime.now(),
      replies: replyList,
      replyCount: json['reply_count'] ?? 0,
      userVote: json['user_vote'],
    );
  }
}
