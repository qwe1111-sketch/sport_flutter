import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final int id;
  final int? parentCommentId;
  final String content;
  final String username;
  final String? userAvatarUrl;
  final int likeCount;
  final int dislikeCount;
  final DateTime createdAt;
  final List<Comment> replies;
  final int replyCount;
  final String? userVote; // Can be 'like', 'dislike', or null

  const Comment({
    required this.id,
    this.parentCommentId,
    required this.content,
    required this.username,
    this.userAvatarUrl,
    required this.likeCount,
    required this.dislikeCount,
    required this.createdAt,
    required this.replyCount,
    this.replies = const [],
    this.userVote,
  });

  Comment copyWith({
    int? id,
    int? parentCommentId,
    String? content,
    String? username,
    String? userAvatarUrl,
    int? likeCount,
    int? dislikeCount,
    DateTime? createdAt,
    List<Comment>? replies,
    int? replyCount,
    String? userVote,
    bool clearUserVote = false,
  }) {
    return Comment(
      id: id ?? this.id,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      content: content ?? this.content,
      username: username ?? this.username,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
      replyCount: replyCount ?? this.replyCount,
      userVote: clearUserVote ? null : userVote ?? this.userVote,
    );
  }

  @override
  List<Object?> get props => [id, parentCommentId, content, username, userAvatarUrl, likeCount, dislikeCount, createdAt, replies, replyCount, userVote];
}
