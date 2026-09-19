import 'package:bcrypt/bcrypt.dart';

import '../../domain/repositories/password_hasher.dart';
import '../../domain/value_objects/password.dart';

class BcryptPasswordHasher implements PasswordHasher {
  @override
  HashedPassword hash(RawPassword password) {
    final hashed = BCrypt.hashpw(password.value, BCrypt.gensalt());
    return HashedPassword(hashed);
  }

  @override
  bool verify(RawPassword password, HashedPassword hash) {
    return BCrypt.checkpw(password.value, hash.value);
  }
}