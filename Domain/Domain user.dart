import 'email.dart';
import 'full_name.dart';
import 'password.dart';
import 'user_id.dart';
import 'user_status.dart';

class User {
  final UserId id;
  final FullName name;
  final Email email;
  final HashedPassword passwordHash;
  final UserStatus status;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.status,
    required this.createdAt,
  });

  User copyWith({UserStatus? status}) => User(
        id: id,
        name: name,
        email: email,
        passwordHash: passwordHash,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}