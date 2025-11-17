import 'package:sport_flutter/data/datasources/auth_remote_data_source.dart';
import 'package:sport_flutter/domain/entities/user.dart';
import 'package:sport_flutter/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  @override
  Future<void> register(String email, String password, String verificationCode) {
    return remoteDataSource.register(email, password, verificationCode);
  }

  @override
  Future<void> sendVerificationCode(String email) {
    return remoteDataSource.sendVerificationCode(email);
  }

  @override
  Future<User> getUserProfile() {
    return remoteDataSource.getUserProfile();
  }

  @override
  Future<User> updateProfile({String? username, String? avatarUrl, String? bio}) {
    return remoteDataSource.updateProfile(
      username: username,
      avatarUrl: avatarUrl,
      bio: bio,
    );
  }
}
