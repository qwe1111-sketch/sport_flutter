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
  final File? mediaFile; // Optional file to upload

  const AddPost({
    required this.title,
    required this.content,
    this.mediaFile,
  });

  @override
  List<Object?> get props => [title, content, mediaFile];
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

    // Only show the full-screen loading shimmer on the initial load.
    if (isInitialLoad) {
      emit(CommunityLoading());
    }

    try {
      final posts = await getCommunityPosts();
      emit(CommunityLoaded(posts));
    } catch (e) {
      // If the refresh fails, we can choose to just log it and keep the old data.
      // If the initial load fails, we must show an error screen.
      if (isInitialLoad) {
        emit(CommunityError('Failed to fetch posts: ${e.toString()}'));
      } else {
        // For a refresh failure, we might not want to disrupt the user with a full error screen.
        // We can just print to the console. The user still sees their (stale) data.
        print('Silent refresh failed: ${e.toString()}');
      }
    }
  }

  Future<void> _onAddPost(AddPost event, Emitter<CommunityState> emit) async {
    // Indicate that posting is in progress.
    emit(CommunityLoading()); 

    try {
      String? imageUrl;
      String? videoUrl;

      if (event.mediaFile != null) {
        final uploadedUrl = await ossUploadService.uploadFile(event.mediaFile!);
        final extension = event.mediaFile!.path.split('.').last.toLowerCase();
        if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
          imageUrl = uploadedUrl;
        } else {
          videoUrl = uploadedUrl;
        }
      }

      await createCommunityPost(
        title: event.title,
        content: event.content,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
      );
      
      emit(CommunityPostSuccess());
      add(FetchPosts());

    } catch (e) {
      print('Failed to create post: ${e.toString()}');
      emit(CommunityError('发帖失败: ${e.toString()}'));
    }
  }
}
