import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sport_flutter/presentation/pages/home_page.dart';
import 'l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;
// ignore: implementation_imports
import 'package:timeago/src/messages/zh_cn_messages.dart';

// Core
import 'package:sport_flutter/presentation/pages/login_page.dart';

// DI - DataSources
import 'package:sport_flutter/data/datasources/auth_remote_data_source.dart';
import 'package:sport_flutter/data/datasources/video_remote_data_source.dart';
import 'package:sport_flutter/data/datasources/community_remote_data_source.dart';
import 'package:sport_flutter/data/datasources/post_comment_remote_data_source.dart';
import 'package:sport_flutter/data/datasources/sts_remote_data_source.dart';

// DI - Repositories
import 'package:sport_flutter/domain/repositories/video_repository.dart';
import 'package:sport_flutter/data/repositories/auth_repository_impl.dart';
import 'package:sport_flutter/data/repositories/video_repository_impl.dart';
import 'package:sport_flutter/data/repositories/community_post_repository_impl.dart';
import 'package:sport_flutter/data/repositories/post_comment_repository_impl.dart';

// DI - UseCases
import 'package:sport_flutter/domain/usecases/login.dart';
import 'package:sport_flutter/domain/usecases/register.dart';
import 'package:sport_flutter/domain/usecases/send_verification_code.dart';
import 'package:sport_flutter/domain/usecases/send_password_reset_code.dart';
import 'package:sport_flutter/domain/usecases/reset_password.dart';
import 'package:sport_flutter/domain/usecases/get_user_profile.dart';
import 'package:sport_flutter/domain/usecases/update_user_profile.dart';
import 'package:sport_flutter/domain/usecases/get_videos.dart';
import 'package:sport_flutter/domain/usecases/get_video_by_id.dart';
import 'package:sport_flutter/domain/usecases/favorite_video.dart';
import 'package:sport_flutter/domain/usecases/unfavorite_video.dart';
import 'package:sport_flutter/domain/usecases/get_favorite_videos.dart';
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
import 'package:sport_flutter/presentation/bloc/locale_bloc.dart';
import 'package:sport_flutter/presentation/bloc/community_bloc.dart';
import 'package:sport_flutter/presentation/bloc/post_comment_bloc.dart';


// Cache
import 'package:sport_flutter/data/cache/video_cache_manager.dart';

// 全局路由观察者
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages('zh', ZhCnMessages());

  // HTTP Clients
  final httpClient = http.Client();
  final dioClient = Dio();

  // DataSources
  final authRemoteDataSource = AuthRemoteDataSourceImpl(client: httpClient);
  final videoRemoteDataSource = VideoRemoteDataSourceImpl(client: httpClient);
  final communityRemoteDataSource = CommunityRemoteDataSourceImpl(client: httpClient);
  final postCommentRemoteDataSource = PostCommentRemoteDataSourceImpl(client: httpClient);
  final stsRemoteDataSource = StsRemoteDataSourceImpl(client: httpClient);

  // Repositories
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);
  final videoRepository = VideoRepositoryImpl(remoteDataSource: videoRemoteDataSource);
  final communityPostRepository = CommunityPostRepositoryImpl(remoteDataSource: communityRemoteDataSource);
  final postCommentRepository = PostCommentRepositoryImpl(remoteDataSource: postCommentRemoteDataSource);

  // UseCases
  final loginUseCase = Login(authRepository);
  final registerUseCase = Register(authRepository);
  final sendCodeUseCase = SendVerificationCode(authRepository);
  final sendPasswordResetCodeUseCase = SendPasswordResetCode(authRepository);
  final resetPasswordUseCase = ResetPassword(authRepository);
  final getUserProfileUseCase = GetUserProfile(authRepository);
  final updateUserProfileUseCase = UpdateUserProfile(authRepository);
  final getVideosUseCase = GetVideos(videoRepository);
  final getVideoByIdUseCase = GetVideoById(videoRepository);
  final favoriteVideoUseCase = FavoriteVideo(videoRepository);
  final unfavoriteVideoUseCase = UnfavoriteVideo(videoRepository);
  final getFavoriteVideosUseCase = GetFavoriteVideos(videoRepository);
  final getCommunityPostsUseCase = GetCommunityPosts(communityPostRepository);
  final getMyPostsUseCase = GetMyPosts(communityPostRepository);
  final createCommunityPostUseCase = CreateCommunityPost(communityPostRepository);
  final deleteCommunityPostUseCase = DeleteCommunityPost(communityPostRepository);
  final getPostCommentsUseCase = GetPostComments(postCommentRepository);
  final createPostCommentUseCase = CreatePostComment(postCommentRepository);
  final likePostCommentUseCase = LikePostCommentUseCase(postCommentRepository);
  final dislikePostCommentUseCase = DislikePostCommentUseCase(postCommentRepository);
  final deletePostCommentUseCase = DeletePostCommentUseCase(postCommentRepository);

  // Services
  final ossUploadService = OssUploadService(stsDataSource: stsRemoteDataSource, dio: dioClient);

  // Cache
  final videoCacheManager = CustomVideoCacheManager().instance;

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider<VideoRepository>.value(value: videoRepository),
        RepositoryProvider.value(value: communityPostRepository),
        RepositoryProvider.value(value: postCommentRepository),
        RepositoryProvider.value(value: ossUploadService),
        RepositoryProvider.value(value: videoCacheManager),
        RepositoryProvider.value(value: getVideosUseCase),
        RepositoryProvider.value(value: getVideoByIdUseCase),
        RepositoryProvider.value(value: getCommunityPostsUseCase),
        RepositoryProvider.value(value: createCommunityPostUseCase),
        RepositoryProvider.value(value: favoriteVideoUseCase),
        RepositoryProvider.value(value: unfavoriteVideoUseCase),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => LocaleBloc()..add(LoadLocale())),
          BlocProvider(
            create: (context) => AuthBloc(
              loginUseCase: loginUseCase,
              registerUseCase: registerUseCase,
              sendCodeUseCase: sendCodeUseCase,
              sendPasswordResetCodeUseCase: sendPasswordResetCodeUseCase,
              resetPasswordUseCase: resetPasswordUseCase,
              getUserProfileUseCase: getUserProfileUseCase,
              updateUserProfileUseCase: updateUserProfileUseCase,
            )..add(AppStarted()), // Dispatch event on creation
          ),
          BlocProvider(
            create: (context) => VideoBloc(
              getVideos: getVideosUseCase,
              favoriteVideo: favoriteVideoUseCase,
              unfavoriteVideo: unfavoriteVideoUseCase,
              cacheManager: videoCacheManager,
            ),
          ),
          BlocProvider(
            create: (context) => MyPostsBloc(getMyPosts: getMyPostsUseCase),
          ),
          BlocProvider(
            create: (context) => FavoritesBloc(getFavoriteVideos: getFavoriteVideosUseCase),
          ),
          BlocProvider(
            create: (context) => CommunityBloc(
              getCommunityPosts: getCommunityPostsUseCase,
              createCommunityPost: createCommunityPostUseCase,
              ossUploadService: ossUploadService,
            ),
          ),
          BlocProvider(
            create: (context) => PostCommentBloc(
              getPostComments: getPostCommentsUseCase,
              createPostComment: createPostCommentUseCase,
              likePostComment: likePostCommentUseCase,
              dislikePostComment: dislikePostCommentUseCase,
              deletePostComment: deletePostCommentUseCase,
              deleteCommunityPost: deleteCommunityPostUseCase,
            ),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, localeState) {
        // Correctly create the text theme without depending on an existing context.
        final baseTextTheme = GoogleFonts.latoTextTheme(ThemeData.light().textTheme);
        final mergedTextTheme = baseTextTheme.copyWith(
          bodyMedium: GoogleFonts.notoSansSc(textStyle: baseTextTheme.bodyMedium),
          displayLarge: GoogleFonts.notoSansSc(textStyle: baseTextTheme.displayLarge),
          displayMedium: GoogleFonts.notoSansSc(textStyle: baseTextTheme.displayMedium),
          displaySmall: GoogleFonts.notoSansSc(textStyle: baseTextTheme.displaySmall),
          headlineMedium: GoogleFonts.notoSansSc(textStyle: baseTextTheme.headlineMedium),
          headlineSmall: GoogleFonts.notoSansSc(textStyle: baseTextTheme.headlineSmall),
          titleLarge: GoogleFonts.notoSansSc(textStyle: baseTextTheme.titleLarge),
        );

        return MaterialApp(
          title: '体育应用',
          locale: localeState.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('zh', ''),
          ],
          theme: ThemeData(
            useMaterial3: true, // Enable Material 3
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple, brightness: Brightness.light),
            scaffoldBackgroundColor: Colors.white,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              unselectedItemColor: Colors.grey,
              elevation: 0,
              // selectedItemColor is now derived from colorScheme.primary
            ),
            tabBarTheme: const TabBarThemeData(
              indicatorSize: TabBarIndicatorSize.label, // Better indicator style
              unselectedLabelColor: Colors.grey,
              // labelColor and indicatorColor are now derived from colorScheme.primary
            ),
            textTheme: mergedTextTheme,
          ),
          navigatorObservers: [routeObserver],
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return const HomePage();
              }
              return const LoginPage();
            },
          ),
        );
      },
    );
  }
}
