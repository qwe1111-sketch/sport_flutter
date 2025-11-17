import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl; // This will now ALWAYS be a full URL provided by the backend.
  final String? bio;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.bio,
  });

  @override
  List<Object?> get props => [id, username, email, avatarUrl, bio];
}
