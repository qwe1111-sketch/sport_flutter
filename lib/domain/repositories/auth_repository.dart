import 'package:sport_flutter/domain/entities/user.dart';

abstract class AuthRepository {
  Future<String> login(String username, String password);
  Future<void> register(String username, String email, String password, String verificationCode);
  Future<void> sendVerificationCode(String email);
  Future<void> sendPasswordResetCode(String email);
  Future<void> resetPassword(String email, String code, String newPassword);
  Future<void> forgotPasswordSendCode(String username, String email);
  Future<void> forgotPasswordReset(String username, String email, String code, String newPassword);
  Future<User> getUserProfile();
  Future<User> updateProfile({String? username, String? avatarUrl, String? bio});
}
