import '../errors/auth_errors.dart';

class FullName {
  final String value;
  FullName._(this.value);

  factory FullName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed.length > 100) {
      throw ValidationError('Name must be 1–100 characters');
    }
    return FullName._(trimmed);
  }

  @override
  String toString() => value;
}