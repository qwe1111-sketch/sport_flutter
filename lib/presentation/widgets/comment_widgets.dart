
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sport_flutter/domain/entities/comment.dart';
import 'package:sport_flutter/presentation/bloc/comment_bloc.dart';

// Helper function to show a single, replaceable replies sheet.
Future<Comment?> _showRepliesSheet(BuildContext context, Comment parentComment) {
  return showModalBottomSheet<Comment>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<CommentBloc>(),
      child: _RepliesSheet(parentComment: parentComment),
    ),
  );
}

/// The main container for the entire comment section.
class CommentSection extends StatefulWidget {
  final int videoId;
  const CommentSection({super.key, required this.videoId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  Comment? _replyingToComment;

  @override
  void initState() {
    super.initState();
    context.read<CommentBloc>().add(FetchComments(widget.videoId));
  }

  void _setReplyingTo(Comment? comment) {
    setState(() => _replyingToComment = comment);
  }

  // This function handles the sheet replacement logic.
  void _handleShowReplies(Comment startingComment) async {
    Comment? nextCommentToShow = startingComment;
    while (nextCommentToShow != null) {
      nextCommentToShow = await _showRepliesSheet(context, nextCommentToShow);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocConsumer<CommentBloc, CommentState>(
            listener: (context, state) {
              // When a post is successful from the main input, clear the target.
              if (state is CommentPostSuccess) {
                _setReplyingTo(null);
              }
            },
            builder: (context, state) {
              // This robust builder logic handles all UI states correctly.
              if (state is CommentLoaded) {
                if (state.comments.isEmpty) {
                  return const Center(child: Text('还没有评论, 快来抢沙发吧!'));
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      context.read<CommentBloc>().add(FetchComments(widget.videoId)),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: state.comments.length,
                    itemBuilder: (context, index) => _CommentItem(
                      comment: state.comments[index],
                      onReply: _setReplyingTo,
                      onShowReplies: _handleShowReplies,
                    ),
                  ),
                );
              }
              if (state is CommentError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              // For ANY other state (Initial, Loading), show the loading indicator.
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        _CommentInputField(
          videoId: widget.videoId,
          replyingToComment: _replyingToComment,
          onCancelReply: () => _setReplyingTo(null),
        ),
      ],
    );
  }
}

/// Renders a single comment item.
class _CommentItem extends StatelessWidget {
  final Comment comment;
  final ValueChanged<Comment> onReply;
  final Function(Comment) onShowReplies;
  final bool isSheetHeader;

  const _CommentItem({
    required this.comment,
    required this.onReply,
    required this.onShowReplies,
    this.isSheetHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: comment.userAvatarUrl != null && comment.userAvatarUrl!.isNotEmpty
                ? NetworkImage(comment.userAvatarUrl!)
                : null,
            child: comment.userAvatarUrl == null || comment.userAvatarUrl!.isEmpty
                ? const Icon(Icons.person_outline)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment.username, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(comment.content),
                const SizedBox(height: 8),
                _buildCommentActions(context),
                if (comment.replyCount > 0 && !isSheetHeader)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextButton(
                      onPressed: () => onShowReplies(comment),
                      child: Text('共${comment.replyCount}条回复 >', style: const TextStyle(fontSize: 12, color: Colors.blueAccent)),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentActions(BuildContext context) {
    final localTime = comment.createdAt.toLocal();
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(DateFormat('MM-dd HH:mm').format(localTime), style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
              const SizedBox(width: 16),
              // Show reply button if it has no replies OR if it is the header of the sheet.
              if (comment.replyCount == 0 || isSheetHeader)
                InkWell(
                  child: const Text('回复', style: TextStyle(fontSize: 12, color: Colors.blueAccent)),
                  onTap: () => onReply(comment),
                ),
            ],
          ),
        ),
        Row(
          children: [
            _buildVoteButton(context, 'like'),
            Text(' ${NumberFormat.compact().format(comment.likeCount)}', style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 16),
            _buildVoteButton(context, 'dislike'),
            const SizedBox(width: 16),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.delete_outline, size: 16),
              onPressed: () => context.read<CommentBloc>().add(DeleteComment(comment.id)),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildVoteButton(BuildContext context, String voteType) {
    final isSelected = comment.userVote == voteType;
    final icon = voteType == 'like'
        ? (isSelected ? Icons.thumb_up : Icons.thumb_up_outlined)
        : (isSelected ? Icons.thumb_down : Icons.thumb_down_outlined);

    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(icon, size: 16),
      onPressed: () => context.read<CommentBloc>().add(VoteComment(comment.id, voteType)),
    );
  }
}


/// The replaceable bottom sheet for replies.
class _RepliesSheet extends StatefulWidget {
  final Comment parentComment;
  const _RepliesSheet({required this.parentComment});

  @override
  State<_RepliesSheet> createState() => _RepliesSheetState();
}

class _RepliesSheetState extends State<_RepliesSheet> {
  late Comment _replyingTo;

  @override
  void initState() {
    super.initState();
    _replyingTo = widget.parentComment;
  }

  @override
  Widget build(BuildContext context) {
    final videoId = context.read<CommentBloc>().currentVideoId;

    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        // Find the latest version of the parent comment from the current state.
        Comment parentComment = widget.parentComment;
        if (state is CommentLoaded) {
            final fullList = state.comments;
            parentComment = _findCommentByIdRecursive(fullList, widget.parentComment.id) ?? widget.parentComment;
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                  color: Color(0xFF222222),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
              child: Column(
                children: [
                  _buildHeader(context, parentComment.replyCount),
                  const Divider(height: 1),
                  _CommentItem(
                      comment: parentComment,
                      onReply: (c) => setState(() => _replyingTo = c),
                      onShowReplies: (parent) {},
                      isSheetHeader: true,
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: parentComment.replies.length,
                      itemBuilder: (context, index) {
                        final reply = parentComment.replies[index];
                        return _CommentItem(
                            comment: reply,
                            onReply: (c) => setState(() => _replyingTo = c),
                            onShowReplies: (parent) => Navigator.of(context).pop(parent),
                        );
                      },
                    ),
                  ),
                  _CommentInputField(
                    videoId: videoId,
                    replyingToComment: _replyingTo,
                    onCancelReply: () => setState(() => _replyingTo = parentComment),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

  Widget _buildHeader(BuildContext context, int replyCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          Text('评论详情 ($replyCount)'),
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}


/// The input field widget.
class _CommentInputField extends StatefulWidget {
  final int videoId;
  final Comment? replyingToComment;
  final VoidCallback onCancelReply;

  const _CommentInputField({
    required this.videoId,
    this.replyingToComment,
    required this.onCancelReply,
  });

  @override
  State<_CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<_CommentInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void didUpdateWidget(covariant _CommentInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.replyingToComment != oldWidget.replyingToComment) {
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

    context.read<CommentBloc>().add(PostComment(
          widget.videoId,
          _controller.text.trim(),
          parentCommentId: widget.replyingToComment?.id,
        ));

    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final hintText = widget.replyingToComment != null
        ? '回复 @${widget.replyingToComment!.username}'
        : '添加评论...';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade800))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.replyingToComment != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  Text('正在回复 @${widget.replyingToComment!.username}', style: Theme.of(context).textTheme.bodySmall),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: widget.onCancelReply,
                  )
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  maxLines: null,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _submitComment,
                color: Colors.blueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
