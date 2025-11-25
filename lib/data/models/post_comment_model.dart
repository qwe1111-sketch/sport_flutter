import 'package:sport_flutter/domain/entities/post_comment.dart';

// The Model is responsible for parsing JSON and creating a data object.
// It is separate from the domain Entity.
class PostCommentModel {
  final int id;
  final String userId;
  final int? parentCommentId;
  final String content;
  final String username;
  final String? userAvatarUrl;
  final int likeCount;
  final int dislikeCount;
  final DateTime createdAt;
  final int replyCount;
  final List<PostCommentModel> replies;
  final String? userVote;

  const PostCommentModel({
    required this.id,
    required this.userId,
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

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    var createdAtString = json['createdAt'] as String;

    // Handle non-standard 'ZZ' suffix from server if it exists
    if (createdAtString.endsWith('ZZ')) {
      createdAtString = createdAtString.substring(0, createdAtString.length - 1);
    }

    // Parse the date string. If it lacks timezone info, it's treated as local time by default.
    final parsedDt = DateTime.parse(createdAtString);

    // Re-create the DateTime object as a UTC time. This corrects the timezone issue
    // by telling Dart that the time values from the server represent UTC.
    final createdAtUtc = DateTime.utc(
      parsedDt.year,
      parsedDt.month,
      parsedDt.day,
      parsedDt.hour,
      parsedDt.minute,
      parsedDt.second,
      parsedDt.millisecond,
      parsedDt.microsecond,
    );

    return PostCommentModel(
      id: json['id'] as int,
      userId: json['userId'].toString(), // Assuming userId can be int or string from json
      parentCommentId: json['parentCommentId'] as int?,
      content: json['content'] as String,
      username: json['username'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      likeCount: json['likeCount'] as int? ?? 0,
      dislikeCount: json['dislikeCount'] as int? ?? 0,
      createdAt: createdAtUtc, // Assign the corrected UTC DateTime
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
      userId: userId,
      parentCommentId: parentCommentId,
      content: content,
      username: username,
      userAvatarUrl: userAvatarUrl,
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
