import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sport_flutter/domain/entities/post_comment.dart';
import 'package:sport_flutter/presentation/bloc/post_comment_bloc.dart';

class CommentInputField extends StatefulWidget {
  final int postId;
  final PostComment? replyingTo;
  final VoidCallback onCancelReply;

  const CommentInputField({super.key, required this.postId, this.replyingTo, required this.onCancelReply});

  @override
  State<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

 @override
  void didUpdateWidget(covariant CommentInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.replyingTo != null && oldWidget.replyingTo != widget.replyingTo) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (_controller.text.trim().isEmpty) return;

    final bloc = context.read<PostCommentBloc>();

    // Optimistic UI update
    final tempComment = PostComment(
      id: -1, // Temporary ID
      content: _controller.text.trim(),
      username: 'wyy', // Placeholder username, replace with actual user
      createdAt: DateTime.now(),
      parentCommentId: widget.replyingTo?.id,
      likeCount: 0,
      dislikeCount: 0,
      replyCount: 0,
    );

    bloc.add(AddCommentOptimistic(tempComment));

    // Send to server in background
    bloc.add(CreateComment(
      postId: widget.postId,
      content: _controller.text.trim(),
      parentCommentId: widget.replyingTo?.id,
    ));

    _controller.clear();
    _focusNode.unfocus();
    widget.onCancelReply(); 
  }

  @override
  Widget build(BuildContext context) {
    final isReplying = widget.replyingTo != null;
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, border: Border(top: BorderSide(color: Colors.grey.shade800, width: 0.5))),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isReplying)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Text('回复 @${widget.replyingTo!.username}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        _focusNode.unfocus();
                        widget.onCancelReply();
                      },
                      child: const Icon(Icons.close, size: 16, color: Colors.grey),
                    )
                  ],
                ),
              ),
            Row(children: [
              Expanded(child: TextField(focusNode: _focusNode, controller: _controller, decoration: InputDecoration.collapsed(hintText: isReplying ? '发送回复...' : '发表你的评论...'))),
              IconButton(icon: const Icon(Icons.send), onPressed: _submitComment)
            ]),
          ],
        ),
      ),
    );
  }
}
