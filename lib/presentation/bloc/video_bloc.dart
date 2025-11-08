import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sport_flutter/domain/repositories/video_repository.dart';
import 'package:sport_flutter/domain/usecases/get_videos.dart';
import 'video_event.dart';
import 'video_state.dart';
import '../../domain/entities/video.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final GetVideos getVideos;
  final CacheManager cacheManager;

  int _page = 1;
  Difficulty _currentDifficulty = Difficulty.Easy;
  List<Video> _videos = [];
  bool _hasReachedMax = false;
  final Map<int, double> _visibilityMap = {};

  VideoBloc({required this.getVideos, required this.cacheManager})
      : super(VideoInitial()) {
    on<FetchVideos>(_onFetchVideos);
    on<UpdateVideoVisibility>(_onUpdateVideoVisibility);
  }

  void _onUpdateVideoVisibility(UpdateVideoVisibility event, Emitter<VideoState> emit) {
    if (event.visibilityFraction > 0) {
      _visibilityMap[event.videoId] = event.visibilityFraction;
    } else {
      _visibilityMap.remove(event.videoId);
    }
    _updateActivePlayer(emit);
  }

  void _updateActivePlayer(Emitter<VideoState> emit) {
    if (state is! VideoLoaded) return;

    int? newActiveId;
    double maxVisibility = 0;

    if (_visibilityMap.isNotEmpty) {
      _visibilityMap.forEach((videoId, visibility) {
        if (visibility > maxVisibility) {
          maxVisibility = visibility;
          newActiveId = videoId;
        }
      });
    }
    
    // --- Pre-caching Logic ---
    if (newActiveId != null) {
      final currentIndex = _videos.indexWhere((v) => v.id == newActiveId);
      if (currentIndex != -1 && currentIndex + 1 < _videos.length) {
        final nextVideoUrl = _videos[currentIndex + 1].videoUrl;
        // Fire and forget. The cache manager will handle the download.
        cacheManager.downloadFile(nextVideoUrl);
      }
    }
    // --- End of Pre-caching Logic ---

    final currentState = state as VideoLoaded;
    if (currentState.activeVideoId != newActiveId) {
      emit(currentState.copyWith(activeVideoId: newActiveId));
    }
  }

  Future<void> _onFetchVideos(FetchVideos event, Emitter<VideoState> emit) async {
    if (event.difficulty != _currentDifficulty) {
      _page = 1;
      _videos = [];
      _hasReachedMax = false;
      _visibilityMap.clear();
      _currentDifficulty = event.difficulty;
      emit(VideoLoading());
    } else if (_hasReachedMax || state is VideoLoading) {
      return;
    }

    try {
      final newVideos = await getVideos(difficulty: _currentDifficulty, page: _page);

      if (newVideos.isEmpty) {
        _hasReachedMax = true;
      } else {
        _page++;
        _videos.addAll(newVideos);
      }

      emit(VideoLoaded(
        videos: List.of(_videos),
        hasReachedMax: _hasReachedMax,
        activeVideoId: (state is VideoLoaded) ? (state as VideoLoaded).activeVideoId : null,
      ));
    } catch (e) {
      emit(VideoError(e.toString()));
    }
  }
}
