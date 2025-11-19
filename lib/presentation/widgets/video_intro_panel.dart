import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sport_flutter/domain/entities/video.dart';
import 'package:sport_flutter/l10n/app_localizations.dart';
import 'package:sport_flutter/presentation/widgets/video_action_buttons.dart';

class VideoIntroPanel extends StatelessWidget {
  final Video currentVideo;
  final List<Video> recommendedVideos;
  final bool isLiked;
  final bool isDisliked;
  final bool isFavorited;
  final bool isInteracting;
  final Function(Video) onChangeVideo;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onFavorite;
  final VoidCallback onShare;

  const VideoIntroPanel({
    super.key,
    required this.currentVideo,
    required this.recommendedVideos,
    required this.isLiked,
    required this.isDisliked,
    required this.isFavorited,
    required this.isInteracting,
    required this.onChangeVideo,
    required this.onLike,
    required this.onDislike,
    required this.onFavorite,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAuthorInfo(context),
                const SizedBox(height: 12),
                Text(currentVideo.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  l10n.videoViews(currentVideo.viewCount, _formatDate(context, currentVideo.createdAt)),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                VideoActionButtons(
                  isLiked: isLiked,
                  isDisliked: isDisliked,
                  isFavorited: isFavorited,
                  isInteracting: isInteracting,
                  likeCount: currentVideo.likeCount,
                  onLike: onLike,
                  onDislike: onDislike,
                  onFavorite: onFavorite,
                  onShare: onShare,
                ),
                const Divider(height: 32),
                Text(l10n.upNext, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (c, i) {
              final v = recommendedVideos[i];
              if (v.id == currentVideo.id) return const SizedBox.shrink();
              return _buildRecommendedItem(c, v);
            },
            childCount: recommendedVideos.length,
          ),
        )
      ],
    );
  }

  Widget _buildAuthorInfo(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: currentVideo.userAvatarUrl != null && currentVideo.userAvatarUrl!.isNotEmpty
              ? NetworkImage(currentVideo.userAvatarUrl!)
              : null,
          child: currentVideo.userAvatarUrl == null || currentVideo.userAvatarUrl!.isEmpty
              ? const Icon(Icons.person)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(currentVideo.authorName, style: Theme.of(context).textTheme.titleMedium)),
        const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildRecommendedItem(BuildContext context, Video video) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () => onChangeVideo(video),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (c, u, e) => const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video.authorName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime d) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 1) return l10n.daysAgo(diff.inDays);
    if (diff.inHours > 1) return l10n.hoursAgo(diff.inHours);
    return l10n.justNow;
  }
}
