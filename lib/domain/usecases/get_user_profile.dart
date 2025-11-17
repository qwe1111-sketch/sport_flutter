import 'package:sport_flutter/domain/entities/user.dart';
import 'package:sport_flutter/domain/repositories/auth_repository.dart';

class GetUserProfile {
  final AuthRepository repository;

  GetUserProfile(this.repository);

  Future<User> call() {
    return repository.getUserProfile();
  }
}
