import 'package:sport_flutter/domain/repositories/auth_repository.dart';

class SendPasswordResetCode {
  final AuthRepository repository;

  SendPasswordResetCode(this.repository);

  Future<void> call(String email) {
    return repository.sendPasswordResetCode(email);
  }
}
