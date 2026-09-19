import '../errors/auth_errors.dart';

class UserId {
  final String value;
  UserId._(this.value);

  factory UserId(String raw) {
    final regex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    if (!regex.hasMatch(raw)) {
      throw ValidationError('Invalid user id');
    }
    return UserId._(raw);
  }

  @override
  bool operator ==(Object other) =>
      other is UserId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}