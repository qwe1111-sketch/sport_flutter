import 'package:sport_flutter/domain/repositories/auth_repository.dart';

class ForgotPasswordReset {
  final AuthRepository repository;

  ForgotPasswordReset(this.repository);

  Future<void> call(String username, String email, String code, String newPassword) {
    return repository.forgotPasswordReset(username, email, code, newPassword);
  }
}
