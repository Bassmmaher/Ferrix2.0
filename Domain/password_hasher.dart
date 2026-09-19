import '../value_objects/password.dart';

abstract class PasswordHasher {
  HashedPassword hash(RawPassword password);
  bool verify(RawPassword password, HashedPassword hash);
}