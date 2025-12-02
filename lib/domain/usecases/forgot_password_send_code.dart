import 'package:sport_flutter/domain/repositories/auth_repository.dart';

class ForgotPasswordSendCode {
  final AuthRepository repository;

  ForgotPasswordSendCode(this.repository);

  Future<void> call(String username, String email) {
    return repository.forgotPasswordSendCode(username, email);
  }
}
