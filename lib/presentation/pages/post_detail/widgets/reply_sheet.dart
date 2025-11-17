import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sport_flutter/domain/entities/post_comment.dart';
import 'package:sport_flutter/presentation/bloc/post_comment_bloc.dart';
import 'package:sport_flutter/presentation/pages/post_detail/widgets/comment_input_field.dart';
import 'package:sport_flutter/presentation/pages/post_detail/widgets/comment_item.dart';

class ReplySheet extends StatefulWidget {
  final int parentCommentId;
  final int postId;
  final ScrollController scrollController;
  
  const ReplySheet({super.key, required this.parentCommentId, required this.postId, required this.scrollController});

  @override
  State<ReplySheet> createState() => _ReplySheetState();
}

class _ReplySheetState extends State<ReplySheet> {
  PostComment? _replyingTo;

  PostComment? _findCommentById(List<PostComment> comments, int id) {
    for (final comment in comments) {
      if (comment.id == id) {
        return comment;
      }
      final foundInReplies = _findCommentById(comment.replies, id);
      if (foundInReplies != null) {
        return foundInReplies;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PostCommentBloc, PostCommentState, PostComment?>(
      selector: (state) {
        if (state is PostCommentLoaded) {
          return _findCommentById(state.comments, widget.parentCommentId);
        }
        return null;
      },
      builder: (context, parentComment) {
        if (parentComment == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_replyingTo == null || _findCommentById([parentComment], _replyingTo!.id) == null){
            _replyingTo = parentComment;
        }

        void _onReplyTapped(PostComment comment) {
          setState(() {
            _replyingTo = comment;
          });
        }

        void _onCancelReply() {
          setState(() {
            _replyingTo = parentComment;
          });
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(10))),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${parentComment.replyCount} 条回复', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: widget.scrollController,
                  itemCount: parentComment.replies.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return CommentItem(comment: parentComment, postId: widget.postId, onReplyTapped: _onReplyTapped, isReply: true, showReplyButton: false);
                    }
                    final reply = parentComment.replies[index - 1];
                    return CommentItem(comment: reply, postId: widget.postId, onReplyTapped: _onReplyTapped, isReply: true);
                  },
                ),
              ),
              CommentInputField(
                postId: widget.postId,
                replyingTo: _replyingTo,
                onCancelReply: _onCancelReply,
              ),
            ],
          ),
        );
      },
    );
  }
}
