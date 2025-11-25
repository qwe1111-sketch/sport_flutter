import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sport_flutter/common/time_formatter.dart';
import 'package:sport_flutter/domain/entities/post_comment.dart';
import 'package:sport_flutter/l10n/app_localizations.dart';
import 'package:sport_flutter/presentation/bloc/auth_bloc.dart';
import 'package:sport_flutter/presentation/bloc/locale_bloc.dart';
import 'package:sport_flutter/presentation/bloc/post_comment_bloc.dart';
import 'package:sport_flutter/presentation/pages/post_detail/widgets/reply_sheet.dart';
import 'package:iconsax/iconsax.dart';

class CommentItem extends StatelessWidget {
  final PostComment comment;
  final int postId;
  final Function(PostComment) onReplyTapped;
  final bool isReply;
  final bool showReplyButton;

  const CommentItem({
    super.key,
    required this.comment,
    required this.postId,
    required this.onReplyTapped,
    this.isReply = false,
    this.showReplyButton = true,
  });

  void _showReplySheet(BuildContext context, PostComment parentComment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<PostCommentBloc>(context),
        child: DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (BuildContext context, ScrollController scrollController) {
            return ReplySheet(parentCommentId: parentComment.id, postId: postId, scrollController: scrollController);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(isReply ? 40.0 : 16.0, 8.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: comment.userAvatarUrl != null && comment.userAvatarUrl!.isNotEmpty
                    ? NetworkImage(comment.userAvatarUrl!)
                    : null,
                child: comment.userAvatarUrl == null || comment.userAvatarUrl!.isEmpty ? const Icon(Iconsax.profile, size: 16) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.username, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(comment.content),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildActionRow(context, Theme.of(context).textTheme, Theme.of(context).colorScheme),
          if (comment.replyCount > 0 && showReplyButton)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: GestureDetector(
                onTap: () => _showReplySheet(context, comment),
                child: Text(localizations.viewAllReplies(comment.replyCount), style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    final bloc = context.read<PostCommentBloc>();
    final voteStyle = textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold);
    final locale = context.watch<LocaleBloc>().state.locale.toLanguageTag();
    final timeString = formatTimestamp(comment.createdAt, locale: locale.replaceAll('-', '_'));
    final authState = context.watch<AuthBloc>().state;
    String? currentUserId;
    if (authState is AuthAuthenticated) {
      currentUserId = authState.user.id;
    }


    return Row(
      children: [
        Text(timeString, style: textTheme.bodySmall?.copyWith(color: Colors.grey)),
        const Spacer(),
        IconButton(
          icon: Icon(Iconsax.like, size: 16, color: comment.userVote == 'like' ? colorScheme.primary : Colors.grey),
          onPressed: () => bloc.add(LikeComment(comment.id)),
        ),
        if (comment.likeCount > 0) Text(comment.likeCount.toString(), style: voteStyle),
        const SizedBox(width: 12),
        IconButton(
          icon: Icon(Iconsax.dislike, size: 16, color: comment.userVote == 'dislike' ? colorScheme.secondary : Colors.grey),
          onPressed: () => bloc.add(DislikeComment(comment.id)),
        ),
        if (comment.dislikeCount > 0) Text(comment.dislikeCount.toString(), style: voteStyle),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Iconsax.message_text_1, size: 16, color: Colors.grey),
          onPressed: () => onReplyTapped(comment),
        ),
        if (currentUserId != null && comment.userId == currentUserId)
          IconButton(
            icon: const Icon(Iconsax.trash, size: 16, color: Colors.grey),
            onPressed: () => bloc.add(DeleteComment(comment.id)),
          ),
      ],
    );
  }
}
