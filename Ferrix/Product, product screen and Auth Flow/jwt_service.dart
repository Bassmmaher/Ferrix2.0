import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtService {
  static final JwtService _instance = JwtService._internal();
  factory JwtService() => _instance;
  JwtService._internal();

  // In production, load from environment variable.
  static const String _secret = 'CHANGE_ME_IN_PRODUCTION';
  static const String _refreshSecret = 'CHANGE_ME_TOO';

  String generateAccessToken(String userId) {
    final jwt = JWT({'sub': userId, 'type': 'access'});
    return jwt.sign(
      SecretKey(_secret),
      expiresIn: const Duration(minutes: 15),
    );
  }

  String generateRefreshToken(String userId) {
    final jwt = JWT({'sub': userId, 'type': 'refresh'});
    return jwt.sign(
      SecretKey(_refreshSecret),
      expiresIn: const Duration(days: 7),
    );
  }

  /// Returns userId or null if invalid.
  String? verifyAccessToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secret));
      return jwt.payload['sub'] as String?;
    } catch (_) {
      return null;
    }
  }
}
