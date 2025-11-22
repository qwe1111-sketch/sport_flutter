import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sport_flutter/domain/entities/community_post.dart';
import 'package:sport_flutter/domain/usecases/get_community_posts.dart';
import 'package:sport_flutter/domain/usecases/create_community_post.dart';
import 'package:sport_flutter/services/oss_upload_service.dart';

// --- Events ---
abstract class CommunityEvent extends Equatable {
  const CommunityEvent();
  @override
  List<Object?> get props => [];
}

class FetchPosts extends CommunityEvent {}

class AddPost extends CommunityEvent {
  final String title;
  final String content;
  final List<File> mediaFiles; // Changed from single file

  const AddPost({
    required this.title,
    required this.content,
    this.mediaFiles = const [], // Default to empty list
  });

  @override
  List<Object?> get props => [title, content, mediaFiles];
}

// --- States ---
abstract class CommunityState extends Equatable {
  const CommunityState();
  @override
  List<Object> get props => [];
}

class CommunityInitial extends CommunityState {}

class CommunityLoading extends CommunityState {}

class CommunityLoaded extends CommunityState {
  final List<CommunityPost> posts;
  const CommunityLoaded(this.posts);
  @override
  List<Object> get props => [posts];
}

class CommunityPostSuccess extends CommunityState {}

class CommunityError extends CommunityState {
  final String message;
  const CommunityError(this.message);
  @override
  List<Object> get props => [message];
}

// --- Bloc ---
class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final GetCommunityPosts getCommunityPosts;
  final CreateCommunityPost createCommunityPost;
  final OssUploadService ossUploadService;

  CommunityBloc({
    required this.getCommunityPosts,
    required this.createCommunityPost,
    required this.ossUploadService,
  }) : super(CommunityInitial()) {
    on<FetchPosts>(_onFetchPosts);
    on<AddPost>(_onAddPost);
  }

  Future<void> _onFetchPosts(FetchPosts event, Emitter<CommunityState> emit) async {
    final isInitialLoad = state is! CommunityLoaded;

    if (isInitialLoad) {
      emit(CommunityLoading());
    }

    try {
      final posts = await getCommunityPosts();
      emit(CommunityLoaded(posts));
    } catch (e) {
      if (isInitialLoad) {
        emit(CommunityError('Failed to fetch posts: ${e.toString()}'));
      } else {
        print('Silent refresh failed: ${e.toString()}');
      }
    }
  }

  Future<void> _onAddPost(AddPost event, Emitter<CommunityState> emit) async {
    emit(CommunityLoading());

    try {
      final List<String> imageUrls = [];
      final List<String> videoUrls = [];

      // Upload all files in parallel and collect their URLs
      if (event.mediaFiles.isNotEmpty) {
        await Future.wait(event.mediaFiles.map((file) async {
          final uploadedUrl = await ossUploadService.uploadFile(file);
          final extension = file.path.split('.').last.toLowerCase();
          if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
            imageUrls.add(uploadedUrl);
          } else {
            videoUrls.add(uploadedUrl);
          }
        }));
      }

      await createCommunityPost(
        title: event.title,
        content: event.content,
        imageUrls: imageUrls,
        videoUrls: videoUrls,
      );
      
      emit(CommunityPostSuccess());
      add(FetchPosts());

    } catch (e) {
      print('Failed to create post: ${e.toString()}');
      emit(CommunityError('发帖失败: ${e.toString()}'));
    }
  }
}
