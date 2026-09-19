import 'dart:math';
import '../entities/user.dart';
import '../enums/user_status.dart';
import '../errors/auth_errors.dart';
import '../value_objects/otp_code.dart';
import '../value_objects/password.dart';

class AuthDomainService {
  final Random _random = Random.secure();

  /// Throws [InvalidCredentialsError] if login is not allowed.
  void assertCanLogin(User user, RawPassword password, bool passwordMatches) {
    if (!passwordMatches) throw InvalidCredentialsError();
    if (user.status != UserStatus.active) throw UserNotVerifiedError();
  }

  /// Generates a 6-digit OTP.
  OtpCode generateOtp() {
    final code = List.generate(6, (_) => _random.nextInt(10)).join();
    return OtpCode.generated(code);
  }
}