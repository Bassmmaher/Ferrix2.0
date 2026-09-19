import '../value_objects/user_id.dart';

class TokenPair {
  final String accessToken;
  final String refreshToken;
  TokenPair({required this.accessToken, required this.refreshToken});
}

abstract class TokenService {
  TokenPair issue(UserId userId);
  UserId? verifyAccess(String token);
}