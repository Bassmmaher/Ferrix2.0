import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../../domain/repositories/token_service.dart';
import '../../domain/value_objects/user_id.dart';

class JwtTokenService implements TokenService {
  final String accessSecret;
  final String refreshSecret;

  JwtTokenService({
    required this.accessSecret,
    required this.refreshSecret,
  });

  @override
  TokenPair issue(UserId userId) {
    final access = JWT({'sub': userId.value, 'type': 'access'}).sign(
      SecretKey(accessSecret),
      expiresIn: const Duration(minutes: 15),
    );
    final refresh = JWT({'sub': userId.value, 'type': 'refresh'}).sign(
      SecretKey(refreshSecret),
      expiresIn: const Duration(days: 7),
    );
    return TokenPair(accessToken: access, refreshToken: refresh);
  }

  @override
  UserId? verifyAccess(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(accessSecret));
      final sub = jwt.payload['sub'] as String?;
      if (sub == null) return null;
      return UserId(sub);
    } catch (_) {
      return null;
    }
  }
}