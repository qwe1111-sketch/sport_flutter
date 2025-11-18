import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sport_flutter/domain/entities/video.dart';
import 'package:sport_flutter/domain/usecases/get_favorite_videos.dart';

// #region States
abstract class FavoritesState extends Equatable {
  const FavoritesState();
  @override
  List<Object> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Video> videos;
  const FavoritesLoaded(this.videos);
  @override
  List<Object> get props => [videos];
}

class FavoritesError extends FavoritesState {
  final String message;
  const FavoritesError(this.message);
  @override
  List<Object> get props => [message];
}
// #endregion

// #region Events
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override
  List<Object> get props => [];
}

class FetchFavorites extends FavoritesEvent {}

class AddFavorite extends FavoritesEvent {
  final Video video;
  const AddFavorite(this.video);
  @override
  List<Object> get props => [video];
}

class RemoveFavorite extends FavoritesEvent {
  final Video video;
  const RemoveFavorite(this.video);
  @override
  List<Object> get props => [video];
}
// #endregion

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoriteVideos getFavoriteVideos;

  FavoritesBloc({required this.getFavoriteVideos}) : super(FavoritesInitial()) {
    on<FetchFavorites>(_onFetchFavorites);
    on<AddFavorite>(_onAddFavorite);
    on<RemoveFavorite>(_onRemoveFavorite);
  }

  void _onFetchFavorites(FetchFavorites event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    try {
      final videos = await getFavoriteVideos();
      emit(FavoritesLoaded(videos));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  void _onAddFavorite(AddFavorite event, Emitter<FavoritesState> emit) {
    final state = this.state;
    if (state is FavoritesLoaded) {
      // Avoid adding duplicates
      if (!state.videos.any((v) => v.id == event.video.id)) {
        emit(FavoritesLoaded(List.from(state.videos)..add(event.video)));
      }
    }
  }

  void _onRemoveFavorite(RemoveFavorite event, Emitter<FavoritesState> emit) {
    final state = this.state;
    if (state is FavoritesLoaded) {
      emit(FavoritesLoaded(
          state.videos.where((video) => video.id != event.video.id).toList()));
    }
  }
}
