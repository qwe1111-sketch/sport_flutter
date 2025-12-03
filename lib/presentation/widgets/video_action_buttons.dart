import 'package:flutter/material.dart';
import 'package:sport_flutter/l10n/app_localizations.dart';
import 'package:iconsax/iconsax.dart';

class VideoActionButtons extends StatelessWidget {
  final bool isLiked;
  final bool isDisliked;
  final bool isFavorited;
  final bool isInteracting;
  final int likeCount;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onFavorite;

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
            icon: Iconsax.like,
            label: _formatNumber(context, likeCount),
            onPressed: onLike,
            isSelected: isLiked,
          ),
        ),
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: isDisliked ? Iconsax.dislike : Iconsax.dislike,
            label: l10n.dislike,
            onPressed: onDislike,
            isSelected: isDisliked,
          ),
        ),
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: isFavorited ? Iconsax.star1 : Iconsax.star,
            label: l10n.favorite,
            onPressed: onFavorite,
            isSelected: isFavorited,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    VoidCallback? onPressed,
  }) {
    final bool isButtonDisabled = isInteracting && (onPressed == onLike || onPressed == onDislike);

    return InkWell(
      borderRadius: BorderRadius.circular(8.0),
      onTap: isButtonDisabled ? null : onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Theme.of(context).colorScheme.primary : (isButtonDisabled ? Colors.grey : Theme.of(context).iconTheme.color),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
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
