import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sport_flutter/domain/entities/post_comment.dart';
import 'package:sport_flutter/domain/usecases/create_post_comment.dart';
import 'package:sport_flutter/domain/usecases/delete_community_post.dart';
import 'package:sport_flutter/domain/usecases/delete_post_comment.dart';
import 'package:sport_flutter/domain/usecases/dislike_post_comment.dart';
import 'package:sport_flutter/domain/usecases/get_post_comments.dart';
import 'package:sport_flutter/domain/usecases/like_post_comment.dart';

// --- Events ---
abstract class PostCommentEvent extends Equatable {
  const PostCommentEvent();
  @override
  List<Object?> get props => [];
}

class FetchPostComments extends PostCommentEvent {
  final int postId;
  const FetchPostComments(this.postId);
  @override
  List<Object> get props => [postId];
}

class CreateComment extends PostCommentEvent {
  final int postId;
  final String content;
  final int? parentCommentId;

  const CreateComment({
    required this.postId,
    required this.content,
    this.parentCommentId,
  });

  @override
  List<Object?> get props => [postId, content, parentCommentId];
}

class AddCommentOptimistic extends PostCommentEvent {
  final PostComment comment;
  const AddCommentOptimistic(this.comment);
  @override
  List<Object?> get props => [comment];
}

class LikeComment extends PostCommentEvent {
  final int commentId;
  const LikeComment(this.commentId);
  @override
  List<Object> get props => [commentId];
}

class DislikeComment extends PostCommentEvent {
  final int commentId;
  const DislikeComment(this.commentId);
  @override
  List<Object> get props => [commentId];
}

class DeleteComment extends PostCommentEvent {
  final int commentId;
  const DeleteComment(this.commentId);
  @override
  List<Object> get props => [commentId];
}

class DeletePost extends PostCommentEvent {
  final int postId;
  const DeletePost(this.postId);
  @override
  List<Object> get props => [postId];
}

// --- States ---
abstract class PostCommentState extends Equatable {
  const PostCommentState();
  @override
  List<Object> get props => [];
}

class PostCommentInitial extends PostCommentState {}

class PostCommentLoading extends PostCommentState {}

class PostDeletionInProgress extends PostCommentState {} // Added this state

class PostDeletionSuccess extends PostCommentState {} // Added this state

class PostDeletionFailure extends PostCommentState {
  final String message;
  const PostDeletionFailure(this.message);
  @override
  List<Object> get props => [message];
} // Added this state

class PostCommentLoaded extends PostCommentState {
  final List<PostComment> comments;
  const PostCommentLoaded(this.comments);
  @override
  List<Object> get props => [comments];
}

class PostCommentError extends PostCommentState {
  final String message;
  const PostCommentError(this.message);
  @override
  List<Object> get props => [message];
}


class PostCommentBloc extends Bloc<PostCommentEvent, PostCommentState> {
  final GetPostComments getPostComments;
  final CreatePostComment createPostComment;
  final LikePostCommentUseCase likePostComment;
  final DislikePostCommentUseCase dislikePostComment;
  final DeletePostCommentUseCase deletePostComment;
  final DeleteCommunityPost deleteCommunityPost; // Added this line

  PostCommentBloc({
    required this.getPostComments,
    required this.createPostComment,
    required this.likePostComment,
    required this.dislikePostComment,
    required this.deletePostComment,
    required this.deleteCommunityPost, // Added this line
  }) : super(PostCommentInitial()) {
    on<FetchPostComments>(_onFetchPostComments);
    on<CreateComment>(_onCreateComment);
    on<AddCommentOptimistic>(_onAddCommentOptimistic);
    on<LikeComment>(_onLikeComment);
    on<DislikeComment>(_onDislikeComment);
    on<DeleteComment>(_onDeleteComment);
    on<DeletePost>(_onDeletePost); // Added this line
  }

  int? _currentPostId;

  // --- Event Handlers ---

  Future<void> _onFetchPostComments(
      FetchPostComments event, Emitter<PostCommentState> emit) async {
    _currentPostId = event.postId;
    emit(PostCommentLoading());
    try {
      final comments = await getPostComments(event.postId);
      emit(PostCommentLoaded(comments));
    } catch (e) {
      emit(PostCommentError('Failed to fetch comments: ${e.toString()}'));
    }
  }

  void _onAddCommentOptimistic(AddCommentOptimistic event, Emitter<PostCommentState> emit) {
    final currentState = state;
    if (currentState is! PostCommentLoaded) return;

    final updatedComments = _addCommentToTree(List.from(currentState.comments), event.comment);
    emit(PostCommentLoaded(updatedComments));
  }

  Future<void> _onCreateComment(
      CreateComment event, Emitter<PostCommentState> emit) async {
    try {
      await createPostComment(CreatePostCommentParams(postId: event.postId, content: event.content, parentCommentId: event.parentCommentId));
      if (_currentPostId != null) {
        final comments = await getPostComments(_currentPostId!);
        emit(PostCommentLoaded(comments));
      }
    } catch (e) {
      emit(PostCommentError('Failed to submit comment: ${e.toString()}'));
      if (_currentPostId != null) {
        add(FetchPostComments(_currentPostId!));
      }
    }
  }

  Future<void> _onDeletePost(DeletePost event, Emitter<PostCommentState> emit) async {
    emit(PostDeletionInProgress());
    try {
      await deleteCommunityPost(event.postId);
      emit(PostDeletionSuccess());
    } catch (e) {
      emit(PostDeletionFailure('Failed to delete post: ${e.toString()}'));
    }
  }

  Future<void> _onLikeComment(
      LikeComment event, Emitter<PostCommentState> emit) async {
    _optimisticallyUpdateVote(event.commentId, 'like', emit);
    try {
      await likePostComment(event.commentId);
    } catch (e) {
      print('Failed to sync like action: ${e.toString()}');
    }
  }

  Future<void> _onDislikeComment(
      DislikeComment event, Emitter<PostCommentState> emit) async {
    _optimisticallyUpdateVote(event.commentId, 'dislike', emit);
    try {
      await dislikePostComment(event.commentId);
    } catch (e) {
      print('Failed to sync dislike action: ${e.toString()}');
    }
  }

  Future<void> _onDeleteComment(DeleteComment event, Emitter<PostCommentState> emit) async {
     final currentState = state;
    if (currentState is! PostCommentLoaded) return;

    final updatedComments = _deleteCommentFromTree(List.from(currentState.comments), event.commentId);
    emit(PostCommentLoaded(updatedComments));

    try {
      await deletePostComment(event.commentId);
    } catch (e) {
      print('Failed to sync delete action: ${e.toString()}');
       if (_currentPostId != null) add(FetchPostComments(_currentPostId!));
    }
  }

  // --- Helper Methods for Recursive State Updates ---

  void _optimisticallyUpdateVote(int commentId, String voteType, Emitter<PostCommentState> emit) {
    final currentState = state;
    if (currentState is! PostCommentLoaded) return;

    final updatedComments = _updateCommentInTree(List.from(currentState.comments), commentId, (comment) {
      String? newVoteStatus = comment.userVote;
      int newLikeCount = comment.likeCount;
      int newDislikeCount = comment.dislikeCount;

      if (voteType == 'like') {
        if (comment.userVote == 'like') { // Un-liking
          newVoteStatus = null;
          newLikeCount--;
        } else { // Liking or switching from dislike
          newVoteStatus = 'like';
          newLikeCount++;
          if (comment.userVote == 'dislike') newDislikeCount--;
        }
      } else { // voteType == 'dislike'
        if (comment.userVote == 'dislike') { // Un-disliking
          newVoteStatus = null;
          newDislikeCount--;
        } else { // Disliking or switching from like
          newVoteStatus = 'dislike';
          newDislikeCount++;
          if (comment.userVote == 'like') newLikeCount--;
        }
      }

      return comment.copyWith(
        userVote: newVoteStatus,
        likeCount: newLikeCount,
        dislikeCount: newDislikeCount,
        clearUserVote: newVoteStatus == null,
      );
    });

    emit(PostCommentLoaded(updatedComments));
  }

  List<PostComment> _updateCommentInTree(List<PostComment> comments, int commentId, PostComment Function(PostComment) updateFn) {
    List<PostComment> newComments = [];
    for (var comment in comments) {
      if (comment.id == commentId) {
        newComments.add(updateFn(comment));
      } else {
        newComments.add(comment.copyWith(replies: _updateCommentInTree(comment.replies, commentId, updateFn)));
      }
    }
    return newComments;
  }

  List<PostComment> _addCommentToTree(List<PostComment> comments, PostComment newComment) {
    if (newComment.parentCommentId == null) {
      return List.from(comments)..add(newComment);
    }
    return comments.map((comment) {
      if (comment.id == newComment.parentCommentId) {
        return comment.copyWith(replies: List.from(comment.replies)..add(newComment), replyCount: comment.replyCount + 1);
      } else {
        return comment.copyWith(replies: _addCommentToTree(comment.replies, newComment));
      }
    }).toList();
  }

  List<PostComment> _deleteCommentFromTree(List<PostComment> comments, int commentId) {
    List<PostComment> result = [];
    for (final comment in comments) {
      if (comment.id == commentId) {
        continue;
      }
      final newReplies = _deleteCommentFromTree(comment.replies, commentId);
      final replyCountDifference = comment.replies.length - newReplies.length;

      result.add(comment.copyWith(
        replies: newReplies,
        replyCount: comment.replyCount - replyCountDifference, 
      ));
    }
    return result;
  }
}
