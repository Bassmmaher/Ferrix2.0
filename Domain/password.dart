import '../errors/auth_errors.dart';

/// Represents a plain-text password during creation/verification.
class RawPassword {
  final String value;
  RawPassword._(this.value);

  factory RawPassword(String raw) {
    if (raw.length < 8) {
      throw ValidationError('Password must be at least 8 characters');
    }
    if (!raw.contains(RegExp(r'[A-Z]'))) {
      throw ValidationError('Password must contain an uppercase letter');
    }
    if (!raw.contains(RegExp(r'[a-z]'))) {
      throw ValidationError('Password must contain a lowercase letter');
    }
    if (!raw.contains(RegExp(r'[0-9]'))) {
      throw ValidationError('Password must contain a digit');
    }
    return RawPassword._(raw);
  }

  @override
  String toString() => '********';
}

/// Represents an already-hashed password (what we store).
class HashedPassword {
  final String value;
  HashedPassword(this.value);

  @override
  bool operator ==(Object other) =>
      other is HashedPassword && other.value == value;

  @override
  int get hashCode => value.hashCode;
}