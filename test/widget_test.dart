import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport_flutter/domain/entities/user.dart';
import 'package:sport_flutter/domain/entities/video.dart';
import 'package:sport_flutter/domain/repositories/auth_repository.dart';
import 'package:sport_flutter/domain/repositories/video_repository.dart';
import 'package:sport_flutter/domain/usecases/get_videos.dart';
import 'package:sport_flutter/domain/usecases/login.dart';
import 'package:sport_flutter/domain/usecases/register.dart';
import 'package:sport_flutter/domain/usecases/send_verification_code.dart';
import 'package:sport_flutter/main.dart';

// --- Mock Implementations for Dependencies ---

// 1. Mock for Authentication
class MockAuthRepository implements AuthRepository {
  @override
  Future<User> login(String username, String password) async {
    if (username == 'test' && password == 'password') {
      return const User(id: '1', username: 'test', email: 'test@example.com');
    }
    throw Exception('Failed to login');
  }

  // Updated to match the new interface
  @override
  Future<void> register(String username, String password, String email, String code) async {
    return;
  }

  // Added to match the new interface
  @override
  Future<void> sendVerificationCode(String email) async {
    return;
  }

  @override
  Future<void> logout() async {
    return;
  }
}

// 2. Mock for Video Repository
class MockVideoRepository implements VideoRepository {
  @override
  Future<List<Video>> getVideos({required Difficulty difficulty, required int page}) async {
    // Return an empty list for simplicity in this test
    return [];
  }
}

// 3. Mock for Cache Manager (implements the BaseCacheManager interface)
class MockCacheManager implements BaseCacheManager {
  @override
  Future<File> getFile(String url, {String? key, Map<String, String>? headers}) =>
      throw UnimplementedError();

  @override
  Stream<FileResponse> getFileStream(String url, {String? key, Map<String, String>? headers, bool? withProgress}) =>
      throw UnimplementedError();

  @override
  Future<FileInfo> downloadFile(String url, {String? key, Map<String, String>? authHeaders, bool force = false}) async {
    // Return a dummy FileInfo to satisfy the method signature
    return FileInfo(File(url), FileSource.NA, DateTime.now().add(const Duration(days: 7)), url);
  }

  @override
  Future<void> putFile(String url, List<int> fileBytes, {String? key, String? eTag, Duration maxAge = const Duration(days: 30), String fileExtension = 'file'}) =>
      throw UnimplementedError();

  @override
  Future<void> putFileStream(String url, Stream<List<int>> source, {String? key, String? eTag, Duration maxAge = const Duration(days: 30), String fileExtension = 'file'}) =>
      throw UnimplementedError();

  @override
  Future<void> removeFile(String key) async {}

  @override
  Future<void> emptyCache() async {}
  
  @override
  Future<FileInfo?> getFileFromCache(String key, {bool ignoreMemCache = false}) async {
    return null;
  }

  @override
  void dispose() {}
}


void main() {
  testWidgets('Login page smoke test', (WidgetTester tester) async {
    // 1. Create all mock instances
    final mockAuthRepository = MockAuthRepository();
    final mockVideoRepository = MockVideoRepository();
    final mockCacheManager = MockCacheManager();

    // 2. Create all use cases with mock repositories
    final loginUseCase = Login(mockAuthRepository);
    final registerUseCase = Register(mockAuthRepository);
    final sendCodeUseCase = SendVerificationCode(mockAuthRepository);
    final getVideosUseCase = GetVideos(mockVideoRepository);

    // 3. Build our app, providing all required dependencies
    await tester.pumpWidget(MyApp(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      sendCodeUseCase: sendCodeUseCase,      // Added
      getVideosUseCase: getVideosUseCase,    // Added
      videoCacheManager: mockCacheManager, // Added
    ));

    // 4. Verify the initial page is LoginPage
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // Verify old counter widgets are not present
    expect(find.text('0'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
  });
}
