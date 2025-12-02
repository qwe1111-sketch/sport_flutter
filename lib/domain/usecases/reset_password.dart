import 'package:sport_flutter/domain/repositories/auth_repository.dart';

class ResetPassword {
  final AuthRepository repository;

  ResetPassword(this.repository);

  Future<void> call(String email, String code, String newPassword) {
    return repository.resetPassword(email, code, newPassword);
  }
}
