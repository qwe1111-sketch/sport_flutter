import 'package:flutter/material.dart';
import 'package:sport_flutter/l10n/app_localizations.dart';

class VideoActionButtons extends StatelessWidget {
  final bool isLiked;
  final bool isDisliked;
  final bool isFavorited;
  final bool isInteracting;
  final int likeCount;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onFavorite;
  final VoidCallback onShare;

  const VideoActionButtons({
    super.key,
    required this.isLiked,
    required this.isDisliked,
    required this.isFavorited,
    required this.isInteracting,
    required this.likeCount,
    required this.onLike,
    required this.onDislike,
    required this.onFavorite,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            label: _formatNumber(context, likeCount),
            onPressed: onLike,
          ),
        ),
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
            label: l10n.dislike,
            onPressed: onDislike,
          ),
        ),
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: isFavorited ? Icons.star : Icons.star_border,
            label: l10n.favorite,
            onPressed: onFavorite,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    // Making the button unresponsive when an interaction is in progress
    final bool isButtonDisabled = isInteracting && (onPressed == onLike || onPressed == onDislike);
    
    return InkWell(
      onTap: isButtonDisabled ? null : onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: isButtonDisabled ? Colors.grey : Theme.of(context).iconTheme.color,
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }

  String _formatNumber(BuildContext context, int n) {
    final l10n = AppLocalizations.of(context)!;
    if (n >= 10000) {
      return '${(n / 10000).toStringAsFixed(1)}${l10n.tenThousand}';
    } 
    return n.toString();
  }
}
