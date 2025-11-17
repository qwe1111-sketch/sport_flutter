import 'package:sport_flutter/domain/entities/user.dart';
import 'package:sport_flutter/domain/repositories/auth_repository.dart';

class UpdateUserProfile {
  final AuthRepository repository;

  UpdateUserProfile(this.repository);

  Future<User> call({String? username, String? avatarUrl, String? bio}) {
    return repository.updateProfile(username: username, avatarUrl: avatarUrl, bio: bio);
  }
}
