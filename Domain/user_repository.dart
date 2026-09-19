import '../entities/user.dart';
import '../value_objects/email.dart';
import '../value_objects/user_id.dart';

abstract class UserRepository {
  Future<User?> findByEmail(Email email);
  Future<User?> findById(UserId id);
  Future<void> save(User user);
  Future<void> update(User user);
}