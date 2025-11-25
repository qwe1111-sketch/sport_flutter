import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sport_flutter/domain/entities/post_comment.dart';
import 'package:sport_flutter/l10n/app_localizations.dart';
import 'package:sport_flutter/presentation/bloc/post_comment_bloc.dart';
import 'package:iconsax/iconsax.dart';

class CommentInputField extends StatefulWidget {
  final int postId;
  final PostComment? replyingTo;
  final VoidCallback onCancelReply;

  const CommentInputField({
    super.key,
    required this.postId,
    required this.replyingTo,
    required this.onCancelReply,
  });

  @override
  State<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  final _controller = TextEditingController();

  void _submitComment() {
    if (_controller.text.trim().isEmpty) return;

    context.read<PostCommentBloc>().add(CreateComment(
      postId: widget.postId,
      content: _controller.text.trim(),
      parentCommentId: widget.replyingTo?.id,
    ));

    _controller.clear();
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    widget.onCancelReply(); // Clear reply target
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final hintText = widget.replyingTo != null
        ? localizations.replyingTo(widget.replyingTo!.username)
        : localizations.postYourComment;

    return Material(
      elevation: 8.0, // Add some shadow
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.replyingTo != null)
              Row(
                children: [
                  Text(localizations.replyingTo(widget.replyingTo!.username)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle, size: 18),
                    onPressed: widget.onCancelReply,
                  ),
                ],
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration.collapsed(hintText: hintText),
                    autofocus: widget.replyingTo != null, // Autofocus when replying
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.send_1),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
