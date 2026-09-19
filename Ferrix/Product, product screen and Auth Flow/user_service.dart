import 'package:bcrypt/bcrypt.dart';
import '../models/user.dart';

/// In-memory user store.
/// Replace with PostgreSQL / MongoDB later — the interface stays the same.
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final Map<String, User> _usersByEmail = {}; // key: lowercase email

  Future<User?> findByEmail(String email) async {
    return _usersByEmail[email.toLowerCase()];
  }

  Future<User?> findById(String id) async {
    return _usersByEmail.values.firstWhere(
      (u) => u.id == id,
      orElse: () => throw StateError('not found'),
    );
  }

  Future<User> create({
    required String id,
    required String name,
    required String email,
    required String plainPassword,
  }) async {
    final hash = BCrypt.hashpw(plainPassword, BCrypt.gensalt());
    final user = User(
      id: id,
      name: name,
      email: email.toLowerCase(),
      passwordHash: hash,
      isVerified: false,
      createdAt: DateTime.now(),
    );
    _usersByEmail[user.email] = user;
    return user;
  }

  bool verifyPassword(String plainPassword, String hash) {
    return BCrypt.checkpw(plainPassword, hash);
  }

  Future<void> markVerified(String email) async {
    final user = _usersByEmail[email.toLowerCase()];
    if (user != null) user.isVerified = true;
  }
}
