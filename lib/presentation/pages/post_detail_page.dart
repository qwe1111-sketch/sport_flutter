import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sport_flutter/domain/entities/community_post.dart';
import 'package:sport_flutter/domain/entities/post_comment.dart';
import 'package:sport_flutter/domain/usecases/create_post_comment.dart';
import 'package:sport_flutter/domain/usecases/delete_community_post.dart';
import 'package:sport_flutter/domain/usecases/delete_post_comment.dart';
import 'package:sport_flutter/domain/usecases/dislike_post_comment.dart';
import 'package:sport_flutter/domain/usecases/get_post_comments.dart';
import 'package:sport_flutter/domain/usecases/like_post_comment.dart';
import 'package:sport_flutter/presentation/bloc/post_comment_bloc.dart';
import 'package:sport_flutter/presentation/pages/post_detail/widgets/comment_input_field.dart';
import 'package:sport_flutter/presentation/pages/post_detail/widgets/comment_section.dart';
import 'package:sport_flutter/presentation/pages/post_detail/widgets/post_header.dart';

class PostDetailPage extends StatelessWidget {
  final CommunityPost post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostCommentBloc(
        getPostComments: RepositoryProvider.of<GetPostComments>(context),
        createPostComment: RepositoryProvider.of<CreatePostComment>(context),
        likePostComment: RepositoryProvider.of<LikePostCommentUseCase>(context),
        dislikePostComment: RepositoryProvider.of<DislikePostCommentUseCase>(context),
        deletePostComment: RepositoryProvider.of<DeletePostCommentUseCase>(context),
        deleteCommunityPost: RepositoryProvider.of<DeleteCommunityPost>(context),
      )..add(FetchPostComments(post.id)),
      child: _PostDetailView(post: post),
    );
  }
}

class _PostDetailView extends StatefulWidget {
  final CommunityPost post;
  const _PostDetailView({required this.post});

  @override
  State<_PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<_PostDetailView> {
  PostComment? _replyingTo;

  void _onReplyTapped(PostComment comment) {
    setState(() {
      _replyingTo = comment;
    });
  }

  void _onCancelReply() {
    setState(() {
      _replyingTo = null;
    });
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('删除帖子'),
          content: const Text('您确定要删除这个帖子吗？此操作无法撤销。'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('删除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                context.read<PostCommentBloc>().add(DeletePost(widget.post.id));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.username),
        actions: [
          // TODO: Replace 'wyy' with a real check for post ownership
          if (widget.post.username == 'wyy') 
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _showDeleteConfirmationDialog,
            ),
        ],
      ),
      body: BlocListener<PostCommentBloc, PostCommentState>(
        listener: (context, state) {
          if (state is PostDeletionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('帖子已成功删除'), duration: Duration(seconds: 1)),
            );
            // THE FIX: Pop with a `true` result to signal the previous page to refresh.
            Navigator.of(context).pop(true);
          } else if (state is PostDeletionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('删除失败: ${state.message}')),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: PostHeader(post: widget.post)),
                  const SliverToBoxAdapter(child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text('评论', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  )),
                  CommentSection(postId: widget.post.id, onReplyTapped: _onReplyTapped),
                ],
              ),
            ),
            CommentInputField(
              postId: widget.post.id,
              replyingTo: _replyingTo,
              onCancelReply: _onCancelReply,
            ),
          ],
        ),
      ),
    );
  }
}
