
import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_flutter/data/datasources/auth_remote_data_source.dart';
import 'package:sport_flutter/data/models/comment_model.dart';
import 'package:sport_flutter/domain/entities/comment.dart';

// region Comment Events
abstract class CommentEvent {}

class FetchComments extends CommentEvent {
  final int videoId;
  FetchComments(this.videoId);
}

class PostComment extends CommentEvent {
  final int videoId;
  final String content;
  final int? parentCommentId;

  PostComment(this.videoId, this.content, {this.parentCommentId});
}

class VoteComment extends CommentEvent {
  final int commentId;
  final String voteType;

  VoteComment(this.commentId, this.voteType);
}

class DeleteComment extends CommentEvent {
  final int commentId;
  DeleteComment(this.commentId);
}
// endregion

// region Comment States
abstract class CommentState {}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentError extends CommentState {
  final String message;
  CommentError(this.message);
}

// A transient state to signal successful posting.
class CommentPostSuccess extends CommentState {}

class CommentLoaded extends CommentState {
  final List<Comment> comments;
  CommentLoaded(this.comments);
}
// endregion

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  // Use the centralized base URL
  final String apiBaseUrl = AuthRemoteDataSourceImpl.getBaseApiUrl();
  int currentVideoId = 0;

  CommentBloc() : super(CommentInitial()) {
    on<FetchComments>(_onFetchComments);
    on<PostComment>(_onPostComment);
    on<VoteComment>(_onVoteComment);
    on<DeleteComment>(_onDeleteComment);
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    return {
      'Content-Type': 'application/json; charset=utf-8',
      if (token != null) 'Authorization': 'Bearer $token'
    };
  }

  Future<void> _onFetchComments(FetchComments event, Emitter<CommentState> emit) async {
    currentVideoId = event.videoId;
    if (state is! CommentLoaded) {
      emit(CommentLoading());
    }
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/comments/video/${event.videoId}'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final comments = data.map((json) => CommentModel.fromJson(json)).toList();
        
        // Recalculate reply counts to include nested replies
        final commentsWithTotalCounts = _recalculateReplyCounts(comments);
        
        emit(CommentLoaded(commentsWithTotalCounts));
      } else {
        emit(CommentError('Failed to load comments. Status: ${response.statusCode}'));
      }
    } catch (e) {
      emit(CommentError('Failed to fetch comments: ${e.toString()}'));
    }
  }

  Future<void> _onPostComment(PostComment event, Emitter<CommentState> emit) async {
    try {
      final headers = await _getAuthHeaders();
      final body = jsonEncode({
        'content': event.content,
        'parentCommentId': event.parentCommentId,
      });

      final response = await http.post(
        Uri.parse('$apiBaseUrl/comments/video/${event.videoId}'),
        headers: headers,
        body: body,
        encoding: Encoding.getByName('utf-8'),
      );

      if (response.statusCode == 201) {
        add(FetchComments(event.videoId));
      } else {
        emit(CommentError('Failed to post comment. Status: ${response.statusCode}'));
      }
    } catch (e) {
      emit(CommentError('Failed to post comment: ${e.toString()}'));
    }
  }
    
  Future<void> _onVoteComment(VoteComment event, Emitter<CommentState> emit) async {
    final currentState = state;
    if (currentState is! CommentLoaded) return;

    final originalComment = _findCommentByIdRecursive(currentState.comments, event.commentId);
    if (originalComment == null) return;

    // --- Comprehensive Optimistic Update --- 
    final String? originalVote = originalComment.userVote;
    final String newVote = event.voteType;

    final bool isCancelling = (originalVote == newVote);
    final String? optimisticUserVote = isCancelling ? null : newVote;

    int optimisticLikeCount = originalComment.likeCount;
    int optimisticDislikeCount = originalComment.dislikeCount;

    if (newVote == 'like') {
      if (originalVote == 'like') { // Case 1: Cancel like
        optimisticLikeCount--;
      } else if (originalVote == 'dislike') { // Case 2: Switch from dislike to like
        optimisticLikeCount++;
        optimisticDislikeCount--;
      } else { // Case 3: New like
        optimisticLikeCount++;
      }
    } else if (newVote == 'dislike') {
      if (originalVote == 'dislike') { // Case 4: Cancel dislike
        optimisticDislikeCount--;
      } else if (originalVote == 'like') { // Case 5: Switch from like to dislike
        optimisticDislikeCount++;
        optimisticLikeCount--;
      } else { // Case 6: New dislike
        optimisticDislikeCount++;
      }
    }

    final optimisticComment = originalComment.copyWith(
      userVote: optimisticUserVote,
      likeCount: optimisticLikeCount,
      dislikeCount: optimisticDislikeCount,
    );
    final optimisticComments = _updateCommentRecursive(List.from(currentState.comments), optimisticComment);
    
    // Emit the optimistic state immediately
    emit(CommentLoaded(optimisticComments));

    // Send request and only revert on failure
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/comments/${event.commentId}/vote'),
        headers: headers,
        body: jsonEncode({'voteType': event.voteType}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        print("!!! VOTE FAILED: Reverting UI. Status: ${response.statusCode}");
        emit(CommentLoaded(currentState.comments));
      }
      // On success, do nothing. The UI is already correct.
      
    } catch (e) {
        print("!!! VOTE FAILED: Reverting UI. Error: $e");
        emit(CommentLoaded(currentState.comments));
    }
  }

  Future<void> _onDeleteComment(DeleteComment event, Emitter<CommentState> emit) async {
     try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/comments/${event.commentId}'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        add(FetchComments(currentVideoId));
      } else {
        print("!!! DELETE FAILED: Status Code ${response.statusCode}, Body: ${response.body}");
      }
    } catch (e) {
      print("!!! DELETE FAILED WITH ERROR: $e");
    }
  }

  List<Comment> _updateCommentRecursive(List<Comment> comments, Comment updatedComment) {
    return comments.map((comment) {
      if (comment.id == updatedComment.id) {
        return updatedComment;
      }
      if (comment.replies.isNotEmpty) {
        return comment.copyWith(replies: _updateCommentRecursive(comment.replies, updatedComment));
      }
      return comment;
    }).toList();
  }

  List<Comment> _recalculateReplyCounts(List<Comment> comments) {
    List<Comment> processedComments = [];
    for (var comment in comments) {
      // Recursively process the replies first to get their updated counts.
      List<Comment> processedReplies = _recalculateReplyCounts(comment.replies);

      // The total count is the number of direct replies + the sum of their total reply counts.
      int totalCount = processedReplies.length;
      for (var reply in processedReplies) {
        totalCount += reply.replyCount;
      }

      // Create a new comment instance with the updated replies and the new total count.
      processedComments.add(comment.copyWith(
        replies: processedReplies,
        replyCount: totalCount,
      ));
    }
    return processedComments;
  }

  Comment? _findCommentByIdRecursive(List<Comment> comments, int id) {
    for (var comment in comments) {
      if (comment.id == id) return comment;
      if (comment.replies.isNotEmpty) {
        final found = _findCommentByIdRecursive(comment.replies, id);
        if (found != null) return found;
      }
    }
    return null;
  }
}
