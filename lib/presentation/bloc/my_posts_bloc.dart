import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sport_flutter/domain/entities/community_post.dart';
import 'package:sport_flutter/domain/usecases/get_my_posts.dart';

// #region States
abstract class MyPostsState extends Equatable {
  const MyPostsState();
  @override
  List<Object> get props => [];
}

class MyPostsInitial extends MyPostsState {}

class MyPostsLoading extends MyPostsState {}

class MyPostsLoaded extends MyPostsState {
  final List<CommunityPost> posts;
  const MyPostsLoaded(this.posts);
  @override
  List<Object> get props => [posts];
}

class MyPostsError extends MyPostsState {
  final String message;
  const MyPostsError(this.message);
  @override
  List<Object> get props => [message];
}
// #endregion

// #region Events
abstract class MyPostsEvent extends Equatable {
  const MyPostsEvent();
  @override
  List<Object> get props => [];
}

class FetchMyPosts extends MyPostsEvent {}
// #endregion

class MyPostsBloc extends Bloc<MyPostsEvent, MyPostsState> {
  final GetMyPosts getMyPosts;

  MyPostsBloc({required this.getMyPosts}) : super(MyPostsInitial()) {
    on<FetchMyPosts>(_onFetchMyPosts);
  }

  void _onFetchMyPosts(FetchMyPosts event, Emitter<MyPostsState> emit) async {
    emit(MyPostsLoading());
    try {
      final posts = await getMyPosts();
      emit(MyPostsLoaded(posts));
    } catch (e) {
      emit(MyPostsError(e.toString()));
    }
  }
}
