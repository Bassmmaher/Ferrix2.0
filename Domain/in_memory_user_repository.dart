import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/user_id.dart';

class InMemoryUserRepository implements UserRepository {
  final Map<String, User> _byEmail = {};

  @override
  Future<User?> findByEmail(Email email) async => _byEmail[email.value];

  @override
  Future<User?> findById(UserId id) async {
    for (final u in _byEmail.values) {
      if (u.id == id) return u;
    }
    return null;
  }

  @override
  Future<void> save(User user) async {
    _byEmail[user.email.value] = user;
  }

  @override
  Future<void> update(User user) async {
    _byEmail[user.email.value] = user;
  }
}