import 'package:sport_flutter/domain/entities/user.dart';

abstract class AuthRepository {
  Future<String> login(String username, String password);
  Future<void> register(String username, String email, String password, String verificationCode);
  Future<void> sendVerificationCode(String email);
  Future<User> getUserProfile();
  Future<User> updateProfile({String? username, String? avatarUrl, String? bio});
}
