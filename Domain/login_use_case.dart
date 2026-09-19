import '../../domain/errors/auth_errors.dart';
import '../../domain/repositories/password_hasher.dart';
import '../../domain/repositories/token_service.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/services/auth_domain_service.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/password.dart';
import '../dto/auth_dtos.dart';

class LoginUseCase {
  final UserRepository _users;
  final PasswordHasher _hasher;
  final TokenService _tokens;
  final AuthDomainService _domain;

  LoginUseCase({
    required UserRepository users,
    required PasswordHasher hasher,
    required TokenService tokens,
    required AuthDomainService domain,
  })  : _users = users,
        _hasher = hasher,
        _tokens = tokens,
        _domain = domain;

  Future<AuthResult> call({
    required String email,
    required String password,
  }) async {
    final voEmail = Email(email);
    final voPassword = RawPassword(password);

    final user = await _users.findByEmail(voEmail);
    // Do not reveal whether email exists → same error for both
    if (user == null) throw InvalidCredentialsError();

    final matches = _hasher.verify(voPassword, user.passwordHash);
    // Enforces both "password correct" AND "status == active"
    _domain.assertCanLogin(user, voPassword, matches);

    final pair = _tokens.issue(user.id);

    return AuthResult(
      accessToken: pair.accessToken,
      refreshToken: pair.refreshToken,
      user: UserDto(
        id: user.id.value,
        name: user.name.value,
        email: user.email.value,
        status: user.status.name,
      ),
    );
  }
}