import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

// Core
import 'package:sport_flutter/presentation/pages/login_page.dart';

// DI - DataSources
import 'package:sport_flutter/data/datasources/auth_remote_data_source.dart';
import 'package:sport_flutter/data/datasources/video_remote_data_source.dart';
import 'package:sport_flutter/data/datasources/community_remote_data_source.dart';
import 'package:sport_flutter/data/datasources/post_comment_remote_data_source.dart';
import 'package:sport_flutter/data/datasources/sts_remote_data_source.dart';

// DI - Repositories
import 'package:sport_flutter/data/repositories/auth_repository_impl.dart';
import 'package:sport_flutter/data/repositories/video_repository_impl.dart';
import 'package:sport_flutter/data/repositories/community_post_repository_impl.dart';
import 'package:sport_flutter/data/repositories/post_comment_repository_impl.dart';

// DI - UseCases
import 'package:sport_flutter/domain/usecases/login.dart';
import 'package:sport_flutter/domain/usecases/register.dart';
import 'package:sport_flutter/domain/usecases/send_verification_code.dart';
import 'package:sport_flutter/domain/usecases/get_user_profile.dart';
import 'package:sport_flutter/domain/usecases/update_user_profile.dart';
import 'package:sport_flutter/domain/usecases/get_videos.dart';
import 'package:sport_flutter/domain/usecases/favorite_video.dart';
import 'package:sport_flutter/domain/usecases/unfavorite_video.dart';
import 'package:sport_flutter/domain/usecases/get_favorite_videos.dart'; // New
import 'package:sport_flutter/domain/usecases/get_community_posts.dart';
import 'package:sport_flutter/domain/usecases/get_my_posts.dart';
import 'package:sport_flutter/domain/usecases/create_community_post.dart';
import 'package:sport_flutter/domain/usecases/delete_community_post.dart';
import 'package:sport_flutter/domain/usecases/get_post_comments.dart';
import 'package:sport_flutter/domain/usecases/create_post_comment.dart';
import 'package:sport_flutter/domain/usecases/like_post_comment.dart';
import 'package:sport_flutter/domain/usecases/dislike_post_comment.dart';
import 'package:sport_flutter/domain/usecases/delete_post_comment.dart';

// DI - Services
import 'package:sport_flutter/services/oss_upload_service.dart';

// DI - BLoCs
import 'package:sport_flutter/presentation/bloc/auth_bloc.dart';
import 'package:sport_flutter/presentation/bloc/my_posts_bloc.dart';
import 'package:sport_flutter/presentation/bloc/video_bloc.dart';
import 'package:sport_flutter/presentation/bloc/favorites_bloc.dart'; // New

// Cache
import 'package:sport_flutter/data/cache/video_cache_manager.dart';

// 全局路由观察者
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final httpClient = http.Client();
  final dioClient = Dio();

  // Auth Dependencies
  final authRemoteDataSource = AuthRemoteDataSourceImpl(client: httpClient);
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);
  final loginUseCase = Login(authRepository);
  final registerUseCase = Register(authRepository);
  final sendCodeUseCase = SendVerificationCode(authRepository);
  final getUserProfileUseCase = GetUserProfile(authRepository);
  final updateUserProfileUseCase = UpdateUserProfile(authRepository);

  // Video Dependencies
  final videoRemoteDataSource = VideoRemoteDataSourceImpl(client: httpClient);
  final videoRepository = VideoRepositoryImpl(remoteDataSource: videoRemoteDataSource);
  final getVideosUseCase = GetVideos(videoRepository);
  final favoriteVideoUseCase = FavoriteVideo(videoRepository);
  final unfavoriteVideoUseCase = UnfavoriteVideo(videoRepository);
  final getFavoriteVideosUseCase = GetFavoriteVideos(videoRepository); // New

  // STS and OSS Dependencies
  final stsRemoteDataSource = StsRemoteDataSourceImpl(client: httpClient);
  final ossUploadService = OssUploadService(stsDataSource: stsRemoteDataSource, dio: dioClient);

  // Community Post Dependencies
  final communityRemoteDataSource = CommunityRemoteDataSourceImpl(client: httpClient);
  final communityPostRepository = CommunityPostRepositoryImpl(remoteDataSource: communityRemoteDataSource);
  final getCommunityPostsUseCase = GetCommunityPosts(communityPostRepository);
  final getMyPostsUseCase = GetMyPosts(communityPostRepository);
  final createCommunityPostUseCase = CreateCommunityPost(communityPostRepository);
  final deleteCommunityPostUseCase = DeleteCommunityPost(communityPostRepository);
  
  // Post Comment Dependencies
  final postCommentRemoteDataSource = PostCommentRemoteDataSourceImpl(client: httpClient);
  final postCommentRepository = PostCommentRepositoryImpl(remoteDataSource: postCommentRemoteDataSource);
  final getPostCommentsUseCase = GetPostComments(postCommentRepository);
  final createPostCommentUseCase = CreatePostComment(postCommentRepository);
  final likePostCommentUseCase = LikePostCommentUseCase(postCommentRepository);
  final dislikePostCommentUseCase = DislikePostCommentUseCase(postCommentRepository);
  final deletePostCommentUseCase = DeletePostCommentUseCase(postCommentRepository);

  // Cache
  final videoCacheManager = CustomVideoCacheManager().instance;

  runApp(
    MyApp(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      sendCodeUseCase: sendCodeUseCase,
      getUserProfileUseCase: getUserProfileUseCase,
      updateUserProfileUseCase: updateUserProfileUseCase,
      getVideosUseCase: getVideosUseCase,
      favoriteVideoUseCase: favoriteVideoUseCase,
      unfavoriteVideoUseCase: unfavoriteVideoUseCase,
      getFavoriteVideosUseCase: getFavoriteVideosUseCase, // New
      getCommunityPostsUseCase: getCommunityPostsUseCase,
      getMyPostsUseCase: getMyPostsUseCase,
      createCommunityPostUseCase: createCommunityPostUseCase,
      deleteCommunityPostUseCase: deleteCommunityPostUseCase,
      getPostCommentsUseCase: getPostCommentsUseCase,
      createPostCommentUseCase: createPostCommentUseCase,
      likePostCommentUseCase: likePostCommentUseCase,
      dislikePostCommentUseCase: dislikePostCommentUseCase,
      deletePostCommentUseCase: deletePostCommentUseCase,
      ossUploadService: ossUploadService, 
      videoCacheManager: videoCacheManager,
    ),
  );
}

class MyApp extends StatelessWidget {
  final Login loginUseCase;
  final Register registerUseCase;
  final SendVerificationCode sendCodeUseCase;
  final GetUserProfile getUserProfileUseCase;
  final UpdateUserProfile updateUserProfileUseCase;
  final GetVideos getVideosUseCase;
  final FavoriteVideo favoriteVideoUseCase;
  final UnfavoriteVideo unfavoriteVideoUseCase;
  final GetFavoriteVideos getFavoriteVideosUseCase; // New
  final GetCommunityPosts getCommunityPostsUseCase;
  final GetMyPosts getMyPostsUseCase;
  final CreateCommunityPost createCommunityPostUseCase;
  final DeleteCommunityPost deleteCommunityPostUseCase;
  final GetPostComments getPostCommentsUseCase;
  final CreatePostComment createPostCommentUseCase;
  final LikePostCommentUseCase likePostCommentUseCase;
  final DislikePostCommentUseCase dislikePostCommentUseCase;
  final DeletePostCommentUseCase deletePostCommentUseCase;
  final OssUploadService ossUploadService; 
  final CacheManager videoCacheManager;

  const MyApp({
    super.key,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.sendCodeUseCase,
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
    required this.getVideosUseCase,
    required this.favoriteVideoUseCase,
    required this.unfavoriteVideoUseCase,
    required this.getFavoriteVideosUseCase, // New
    required this.getCommunityPostsUseCase,
    required this.getMyPostsUseCase,
    required this.createCommunityPostUseCase,
    required this.deleteCommunityPostUseCase,
    required this.getPostCommentsUseCase,
    required this.createPostCommentUseCase,
    required this.likePostCommentUseCase,
    required this.dislikePostCommentUseCase,
    required this.deletePostCommentUseCase,
    required this.ossUploadService, 
    required this.videoCacheManager,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: getUserProfileUseCase),
        RepositoryProvider.value(value: updateUserProfileUseCase),
        RepositoryProvider.value(value: getVideosUseCase),
        RepositoryProvider.value(value: favoriteVideoUseCase),
        RepositoryProvider.value(value: unfavoriteVideoUseCase),
        RepositoryProvider.value(value: getFavoriteVideosUseCase), // New
        RepositoryProvider.value(value: getCommunityPostsUseCase),
        RepositoryProvider.value(value: getMyPostsUseCase),
        RepositoryProvider.value(value: createCommunityPostUseCase),
        RepositoryProvider.value(value: deleteCommunityPostUseCase),
        RepositoryProvider.value(value: getPostCommentsUseCase),
        RepositoryProvider.value(value: createPostCommentUseCase),
        RepositoryProvider.value(value: likePostCommentUseCase),
        RepositoryProvider.value(value: dislikePostCommentUseCase),
        RepositoryProvider.value(value: deletePostCommentUseCase),
        RepositoryProvider.value(value: ossUploadService), 
        RepositoryProvider.value(value: videoCacheManager),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              loginUseCase: loginUseCase,
              registerUseCase: registerUseCase,
              sendCodeUseCase: sendCodeUseCase,
              getUserProfileUseCase: getUserProfileUseCase,
              updateUserProfileUseCase: updateUserProfileUseCase,
            ),
          ),
          BlocProvider<VideoBloc>(
            create: (context) => VideoBloc(
              getVideos: getVideosUseCase,
              favoriteVideo: favoriteVideoUseCase,
              unfavoriteVideo: unfavoriteVideoUseCase,
              cacheManager: videoCacheManager,
            ),
          ),
          BlocProvider<MyPostsBloc>(
            create: (context) => MyPostsBloc(
              getMyPosts: getMyPostsUseCase,
            ),
          ),
          BlocProvider<FavoritesBloc>(
            create: (context) => FavoritesBloc(
              getFavoriteVideos: getFavoriteVideosUseCase,
            ),
          ), // New
        ],
        child: MaterialApp(
          title: '体育应用',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.dark,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'NotoSansSC',
          ),
          navigatorObservers: [routeObserver],
          home: LoginPage(),
        ),
      ),
    );
  }
}
