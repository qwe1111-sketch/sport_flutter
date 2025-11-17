import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommentItemPlaceholder extends StatelessWidget {
  const CommentItemPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[800]!,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(radius: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 100, height: 14, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: double.infinity, height: 16, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(width: 200, height: 16, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 80, height: 12, color: Colors.white),
                const Spacer(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
