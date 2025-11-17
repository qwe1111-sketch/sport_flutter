import 'package:sport_flutter/domain/repositories/auth_repository.dart';

class Login {
  final AuthRepository repository;

  Login(this.repository);

  // This use case now correctly takes email and password, 
  // and returns a Future<String> (the token) to match the repository's contract.
  Future<String> call(String email, String password) {
    return repository.login(email, password);
  }
}
