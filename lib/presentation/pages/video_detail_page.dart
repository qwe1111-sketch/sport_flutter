
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_flutter/data/cache/video_cache_manager.dart';
import 'package:sport_flutter/data/datasources/auth_remote_data_source.dart';
import 'package:sport_flutter/domain/entities/video.dart';
import 'package:sport_flutter/domain/usecases/favorite_video.dart';
import 'package:sport_flutter/domain/usecases/get_video_by_id.dart';
import 'package:sport_flutter/domain/usecases/unfavorite_video.dart';
import 'package:sport_flutter/l10n/app_localizations.dart';
import 'package:sport_flutter/presentation/bloc/comment_bloc.dart';
import 'package:sport_flutter/presentation/bloc/favorites_bloc.dart';
import 'package:sport_flutter/presentation/bloc/video_bloc.dart';
import 'package:sport_flutter/presentation/bloc/video_event.dart';
import 'package:sport_flutter/presentation/bloc/video_state.dart';
import 'package:sport_flutter/presentation/widgets/comment_widgets.dart';
import 'package:sport_flutter/presentation/widgets/video_intro_panel.dart';
import 'package:sport_flutter/presentation/widgets/video_player_widget.dart';
import 'package:video_player/video_player.dart';

class VideoDetailPage extends StatefulWidget {
  final Video video;

  const VideoDetailPage({
    super.key,
    required this.video,
  });

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late VideoPlayerController _controller;
  late Video _currentVideo;
  late final CommentBloc _commentBloc;
  late Future<void> _initializeVideoPlayerFuture;

  bool _isFullScreen = false;
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _isFavorited = false;
  bool _viewRecorded = false;
  bool _isInteracting = false;
  bool _isLoading = true;

  final String _apiBaseUrl = AuthRemoteDataSourceImpl.getBaseApiUrl();

  // Baidu Translate Credentials
  final String _baiduAppId = '20230522001685444';
  final String _baiduSecretKey = 'qcEQl156_3sdFvOXTLup';

  // In-memory cache for translations
  final Map<String, String> _translationCache = {};

  String _translatedTitle = "";
  String _translatedDesc = "";

  @override
  void initState() {
    super.initState();
    _currentVideo = widget.video;
    _commentBloc = CommentBloc();
    _initializeVideoPlayerFuture = _initializePlayer(_currentVideo.videoUrl);
    
    _commentBloc.add(FetchComments(_currentVideo.id));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchFullVideoDetails();
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    _commentBloc.close();
    if (_isFullScreen) {
      _exitFullScreen();
    }
    super.dispose();
  }
  
  Future<void> _fetchFullVideoDetails({int? videoId}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final idToFetch = videoId ?? widget.video.id;
      final fullVideo = await context.read<GetVideoById>()(idToFetch);
      
      if (mounted) {
        setState(() {
          _currentVideo = fullVideo;
          _isFavorited = fullVideo.isFavorited;
        });
        
        final currentLocale = Localizations.localeOf(context).languageCode;
        await _translateContent(currentLocale);

        context.read<VideoBloc>().add(FetchVideosByDifficulty(_currentVideo.difficulty));
        await _fetchInteractiveStatus();
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString();
        if (errorMessage.contains('Video not found')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('该视频已被删除')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load full video details: $e')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String> _manualBaiduTranslate(String query, String toLang) async {
    final cacheKey = '$toLang:$query';
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }

    const String baseUrl = 'https://fanyi-api.baidu.com/api/trans/vip/translate';
    final String salt = Random().nextInt(100000).toString();
    final String sign = md5.convert(utf8.encode('$_baiduAppId$query$salt$_baiduSecretKey')).toString();

    final uri = Uri.parse(baseUrl).replace(queryParameters: {
      'q': query,
      'from': 'auto',
      'to': toLang,
      'appid': _baiduAppId,
      'salt': salt,
      'sign': sign,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['trans_result'] != null && body['trans_result'].isNotEmpty) {
        final translatedText = body['trans_result'][0]['dst'];
        _translationCache[cacheKey] = translatedText;
        return translatedText;
      } else if (body['error_code'] != null) {
        throw Exception('Baidu API Error: ${body['error_msg']} (code: ${body['error_code']})');
      }
    }
    throw Exception('Failed to translate text.');
  }

  Future<void> _translateContent(String toLang) async {
    if (toLang == 'zh') {
      if (mounted) {
        setState(() {
          _translatedTitle = _currentVideo.title;
          _translatedDesc = _currentVideo.description ?? '';
        });
      }
      return;
    }

    try {
      final titleTranslation = _manualBaiduTranslate(_currentVideo.title, toLang);
      final descTranslation = _manualBaiduTranslate(_currentVideo.description ?? '', toLang);

      final results = await Future.wait([titleTranslation, descTranslation]);

      if (mounted) {
        setState(() {
          _translatedTitle = results[0];
          _translatedDesc = results[1];
        });
      }
      
    } catch (e) {
      debugPrint("翻译失败：$e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('翻译失败: $e')),
        );
        setState(() {
          _translatedTitle = _currentVideo.title;
          _translatedDesc = _currentVideo.description ?? '';
        });
      }
    }
  }

  Future<void> _fetchInteractiveStatus() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/videos/${_currentVideo.id}/status'),
        headers: headers,
      );
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        setState(() {
          _isLiked = data['isLikedByUser'] ?? false;
          _isDisliked = data['isDislikedByUser'] ?? false;
           _currentVideo = _currentVideo.copyWith(
            likeCount: data['like_count'] ?? _currentVideo.likeCount,
          );
        });
      }
    } catch (_) {
      // Silently fail or log error, as this is non-critical data
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token'
    };
  }

  Future<void> _initializePlayer(String url) async {
    final fileInfo = await CustomVideoCacheManager().instance.getFileFromCache(url);

    if (fileInfo != null) {
      _controller = VideoPlayerController.file(fileInfo.file);
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      CustomVideoCacheManager().instance.downloadFile(url);
    }

    _controller.addListener(_videoListener);
    try {
      await _controller.initialize();
      if (mounted) {
        _controller.play();
      }
    } catch (e) {
      if (mounted) {
        debugPrint("Video Player Initialization Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("无法加载视频: $e"),
          ),
        );
      }
    }
  }

  Future<void> _changeVideo(Video newVideo) async {
    if (!mounted) return;

    await _controller.dispose();
    setState(() {
      _isLoading = true;
      _viewRecorded = false;
      _initializeVideoPlayerFuture = _initializePlayer(newVideo.videoUrl);
    });

    _commentBloc.add(FetchComments(newVideo.id));
    await _fetchFullVideoDetails(videoId: newVideo.id);
  }

  void _videoListener() {
    if (!_viewRecorded &&
        _controller.value.isInitialized &&
        !_controller.value.hasError &&
        _controller.value.position >= _controller.value.duration) {
      _recordView();
      _viewRecorded = true;
    }
  }

  Future<void> _recordView() async {
    try {
      final headers = await _getAuthHeaders();
      await http.post(
        Uri.parse('$_apiBaseUrl/videos/${_currentVideo.id}/view'),
        headers: headers,
      );
    } catch (_) {
      // Handle error silently
    }
  }

  Future<void> _toggleLike() async => _performVoteAction('like');
  Future<void> _toggleDislike() async => _performVoteAction('dislike');

  Future<void> _toggleFavorite() async {
    final isCurrentlyFavorited = _isFavorited;
    setState(() {
      _isFavorited = !isCurrentlyFavorited;
    });

    final favoritesBloc = context.read<FavoritesBloc>();

    try {
      if (isCurrentlyFavorited) {
        await context.read<UnfavoriteVideo>()(_currentVideo.id);
        favoritesBloc.add(RemoveFavorite(_currentVideo));
      } else {
        await context.read<FavoriteVideo>()(_currentVideo.id);
        favoritesBloc.add(AddFavorite(_currentVideo));
      }
    } catch (e) {
      setState(() {
        _isFavorited = isCurrentlyFavorited;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Operation failed: $e')),
        );
      }
    }
  }

  Future<void> _performVoteAction(String action) async {
    if (_isInteracting) return;
    setState(() => _isInteracting = true);

    final bool previousIsLiked = _isLiked;
    final bool previousIsDisliked = _isDisliked;
    final int previousLikeCount = _currentVideo.likeCount;

    bool newIsLiked = previousIsLiked;
    bool newIsDisliked = previousIsDisliked;
    int newLikeCount = previousLikeCount;

    if (action == 'like') {
      if (previousIsLiked) {
        newIsLiked = false;
        newLikeCount--;
      } else {
        newIsLiked = true;
        newLikeCount++;
        if (previousIsDisliked) {
          newIsDisliked = false;
        }
      }
    } else if (action == 'dislike') {
      if (previousIsDisliked) {
        newIsDisliked = false;
      } else {
        newIsDisliked = true;
        if (previousIsLiked) {
          newIsLiked = false;
          newLikeCount--;
        }
      }
    }

    setState(() {
      _isLiked = newIsLiked;
      _isDisliked = newIsDisliked;
      _currentVideo = _currentVideo.copyWith(likeCount: newLikeCount);
    });

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/videos/${_currentVideo.id}/$action'),
        headers: headers,
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to perform vote action: ${response.statusCode}');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLiked = previousIsLiked;
          _isDisliked = previousIsDisliked;
          _currentVideo = _currentVideo.copyWith(likeCount: previousLikeCount);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isInteracting = false);
      }
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        _exitFullScreen();
      }
    });
  }

  void _exitFullScreen() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    final playerWidget = FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _controller.value.isInitialized) {
          return VideoPlayerWidget(
            controller: _controller,
            isFullScreen: _isFullScreen,
            onToggleFullScreen: _toggleFullScreen,
          );
        }
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: Colors.black,
            child: const Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );

    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: playerWidget),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) {
            if (didPop) return;
            Navigator.of(context).pop(result as bool?);
          },
          child: BlocProvider.value(
            value: _commentBloc,
            child: DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[SliverAppBar(
                      title: Text(_translatedTitle),                      floating: true,
                      pinned: false,
                      snap: true,
                    ),
                    SliverToBoxAdapter(
                      child: playerWidget,
                    ),
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          tabs: [
                            Tab(text: AppLocalizations.of(context)!.introduction),
                            Tab(text: AppLocalizations.of(context)!.comments),
                          ],
                        ),
                      ),
                      pinned: true,
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : BlocBuilder<VideoBloc, VideoState>(
                            builder: (context, state) {
                              List<Video> recommendedVideos = [];
                              if (state is VideoLoaded) {
                                recommendedVideos = state.videos;
                              }
                              return VideoIntroPanel(
                                currentVideo: _currentVideo.copyWith(title: _translatedTitle, description: _translatedDesc),
                                recommendedVideos: recommendedVideos,
                                isLiked: _isLiked,
                                isDisliked: _isDisliked,
                                isFavorited: _isFavorited,
                                isInteracting: _isInteracting,
                                onChangeVideo: _changeVideo,
                                onLike: _toggleLike,
                                onDislike: _toggleDislike,
                                onFavorite: _toggleFavorite,
                              );
                            },
                          ),
                    CommentSection(videoId: _currentVideo.id),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return oldDelegate._tabBar != _tabBar;
  }
}
