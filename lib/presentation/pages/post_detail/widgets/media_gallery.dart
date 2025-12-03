import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import './full_screen_media_viewer.dart';

class MediaGallery extends StatefulWidget {
  final List<String> imageUrls;

  const MediaGallery({super.key, required this.imageUrls});

  @override
  State<MediaGallery> createState() => _MediaGalleryState();
}

class _MediaGalleryState extends State<MediaGallery> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) return const SizedBox.shrink();
    if (widget.imageUrls.length == 1) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => FullScreenMediaViewer(
              mediaUrls: widget.imageUrls,
              initialIndex: 0,
            ),
          ));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: widget.imageUrls.first,
              fit: BoxFit.cover,
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              placeholder: (context, url) => Container(color: Colors.grey.shade200),
              errorWidget: (context, url, error) => Container(color: Colors.grey.shade200, child: const Icon(Icons.error, color: Colors.grey)),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => FullScreenMediaViewer(
                      mediaUrls: widget.imageUrls,
                      initialIndex: index,
                    ),
                  ));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrls[index],
                    fit: BoxFit.cover,
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    placeholder: (context, url) => Container(color: Colors.grey.shade200),
                    errorWidget: (context, url, error) => Container(color: Colors.grey.shade200, child: const Icon(Icons.error, color: Colors.grey)),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.imageUrls.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imageUrls.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                width: _currentPage == index ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Theme.of(context).primaryColor : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          )
      ],
    );
  }
}
