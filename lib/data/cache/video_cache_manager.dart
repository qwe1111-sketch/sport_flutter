import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// A custom cache manager for our videos.
// This allows us to have a separate cache configuration for videos.
class CustomVideoCacheManager {
  static const key = 'customVideoCacheKey';

  static final CustomVideoCacheManager _instance = CustomVideoCacheManager._();

  factory CustomVideoCacheManager() {
    return _instance;
  }

  CustomVideoCacheManager._()
      : _cacheManager = CacheManager(
          Config(
            key,
            // Videos are large, so we might want a shorter stale period
            // and a smaller number of objects compared to images.
            stalePeriod: const Duration(days: 7), // How long a file stays in cache
            maxNrOfCacheObjects: 50,             // Max number of videos in cache
            repo: JsonCacheInfoRepository(databaseName: key),
            fileService: HttpFileService(),
          ),
        );

  final CacheManager _cacheManager;

  // Getter to access the singleton instance of the CacheManager
  CacheManager get instance => _cacheManager;
}
