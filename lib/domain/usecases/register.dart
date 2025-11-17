import 'package:sport_flutter/domain/repositories/auth_repository.dart';

class Register {
  final AuthRepository repository;

  Register(this.repository);

  // This use case now correctly takes email, password, and code,
  // and calls the repository with the correct arguments to match its contract.
  Future<void> call(String email, String password, String code) {
    return repository.register(email, password, code);
  }
}
