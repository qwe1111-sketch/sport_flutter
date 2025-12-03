import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sport_flutter/presentation/bloc/community_bloc.dart';
import 'package:sport_flutter/domain/entities/community_post.dart';
import 'package:sport_flutter/presentation/pages/create_post_page.dart';
import 'package:sport_flutter/presentation/pages/post_detail_page.dart';
import 'package:video_player/video_player.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sport_flutter/l10n/app_localizations.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  void initState() {
    super.initState();
    context.read<CommunityBloc>().add(FetchPosts());
  }

  @override
  Widget build(BuildContext context) {
    return const _CommunityView();
  }
}

class _CommunityView extends StatelessWidget {
  const _CommunityView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.community),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<CommunityBloc, CommunityState>(
        listener: (context, state) {
          if (state is CommunityError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text('操作失败: ${state.message}')));
          }
          if (state is CommunityPostSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('发表成功!')));
          }
        },
        builder: (context, state) {
          if (state is CommunityLoaded) {
            if (state.posts.isEmpty) {
              return const Center(child: Text('还没有人发言，快来抢个沙发吧！'));
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<CommunityBloc>().add(FetchPosts()),
              child: ListView.separated(
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return _PostItem(key: ValueKey(post.id), post: post);
                },
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              ),
            );
          }
          if (state is CommunityError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('加载失败'),
                  const SizedBox(height: 8),
                  TextButton(onPressed: () => context.read<CommunityBloc>().add(FetchPosts()), child: const Text('点击重试')),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CommunityBloc>(),
                child: const CreatePostPage(),
              ),
            ),
          );
        },
        backgroundColor: Colors.purple.shade100,
        child: const Icon(Iconsax.add),
      ),
    );
  }
}

class _PostItem extends StatefulWidget {
  final CommunityPost post;
  const _PostItem({super.key, required this.post});
  @override
  State<_PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<_PostItem> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.post.videoUrls.isNotEmpty) {
      _initializeVideoPlayerFuture = _initVideoPlayer();
    }
  }

  Future<void> _initVideoPlayer() async {
    final videoUrl = widget.post.videoUrls.first;
    try {
      final file = await DefaultCacheManager().getSingleFile(videoUrl);
      _controller = VideoPlayerController.file(file);
    } catch (e) {
      debugPrint('Error loading video from cache, falling back to network: $e');
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    }
    
    _controller!.setLooping(true);
    await _controller!.initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildVideoPlayer() {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && _controller != null && _controller!.value.isInitialized) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.play, color: Colors.white, size: 48),
                ),
              ],
            ),
          );
        } else {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CommunityBloc>(),
                child: PostDetailPage(post: widget.post),
              ),
        ));
        if (result == true && mounted) {
          context.read<CommunityBloc>().add(FetchPosts());
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [CircleAvatar(radius: 12, backgroundImage: widget.post.userAvatarUrl != null && widget.post.userAvatarUrl!.isNotEmpty ? CachedNetworkImageProvider(widget.post.userAvatarUrl!) : null, child: widget.post.userAvatarUrl == null || widget.post.userAvatarUrl!.isEmpty ? const Icon(Iconsax.profile, size: 14) : null,), const SizedBox(width: 8), Text(widget.post.username, style: Theme.of(context).textTheme.bodySmall)]),
            const SizedBox(height: 8),
            Text(widget.post.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.post.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
            if (widget.post.imageUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: widget.post.imageUrls.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey.shade200),
                      errorWidget: (context, url, error) => Container(color: Colors.grey.shade200, child: const Icon(Icons.error, color: Colors.grey)),
                    ),
                  ),
                ),
              ),
            if (widget.post.videoUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: _buildVideoPlayer(),
                ),
              ),
            const SizedBox(height: 12),
            Row(children: [if (widget.post.tags?.isNotEmpty ?? false) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(widget.post.tags!.first, style: TextStyle(color: Colors.blue.shade700, fontSize: 10)))]),
          ],
        ),
      ),
    );
  }
}
