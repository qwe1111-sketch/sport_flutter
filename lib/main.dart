import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_flutter/data/cache/video_cache_manager.dart';
import 'package:sport_flutter/data/datasources/auth_remote_data_source.dart';
import 'package:sport_flutter/data/datasources/video_remote_data_source.dart';
import 'package:sport_flutter/data/repositories/auth_repository_impl.dart';
import 'package:sport_flutter/data/repositories/video_repository_impl.dart';
import 'package:sport_flutter/domain/usecases/get_videos.dart';
import 'package:sport_flutter/domain/usecases/login.dart';
import 'package:sport_flutter/domain/usecases/register.dart';
import 'package:sport_flutter/domain/usecases/send_verification_code.dart';
import 'package:sport_flutter/presentation/bloc/auth_bloc.dart';
import 'package:sport_flutter/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Dependency Injection ---
  final client = http.Client();

  // Auth Dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  final authRemoteDataSource = AuthRemoteDataSourceImpl(client: client, sharedPreferences: sharedPreferences);
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);
  final loginUseCase = Login(authRepository);
  final registerUseCase = Register(authRepository);
  final sendCodeUseCase = SendVerificationCode(authRepository);

  // Video Dependencies
  final videoRemoteDataSource = VideoRemoteDataSourceImpl(client: client);
  final videoRepository = VideoRepositoryImpl(remoteDataSource: videoRemoteDataSource);
  final getVideosUseCase = GetVideos(videoRepository);

  // Cache Manager Dependency
  final videoCacheManager = CustomVideoCacheManager();

  runApp(
    MyApp(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      sendCodeUseCase: sendCodeUseCase,
      getVideosUseCase: getVideosUseCase,
      videoCacheManager: videoCacheManager.instance,
    ),
  );
}

class MyApp extends StatelessWidget {
  final Login loginUseCase;
  final Register registerUseCase;
  final SendVerificationCode sendCodeUseCase;
  final GetVideos getVideosUseCase;
  final CacheManager videoCacheManager;

  const MyApp({
    super.key,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.sendCodeUseCase,
    required this.getVideosUseCase,
    required this.videoCacheManager,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Provide dependencies to the widget tree
        RepositoryProvider.value(value: getVideosUseCase),
        RepositoryProvider.value(value: videoCacheManager),
      ],
      child: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(
          loginUseCase: loginUseCase,
          registerUseCase: registerUseCase,
          sendCodeUseCase: sendCodeUseCase,
        ),
        child: MaterialApp(
          title: 'Video App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.dark,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: LoginPage(),
        ),
      ),
    );
  }
}
