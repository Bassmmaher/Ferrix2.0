class UserDto {
  final String id;
  final String name;
  final String email;
  final String status;

  UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
  });
}

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final UserDto user;
  AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}