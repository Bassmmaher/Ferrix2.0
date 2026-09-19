import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../../domain/enums/otp_purpose.dart';
import '../../domain/enums/user_status.dart';
import '../../domain/errors/auth_errors.dart';
import '../../domain/repositories/otp_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/otp_code.dart';

class VerifyEmailUseCase {
  final UserRepository _users;
  final OtpRepository _otps;

  VerifyEmailUseCase({
    required UserRepository users,
    required OtpRepository otps,
  })  : _users = users,
        _otps = otps;

  Future<void> call({required String email, required String otp}) async {
    final voEmail = Email(email);
    final voOtp = OtpCode(otp); // validates 6-digit format

    final user = await _users.findByEmail(voEmail);
    if (user == null) throw UserNotFoundError();
    if (user.status == UserStatus.active) return; // already verified

    final entry = await _otps.find(voEmail, OtpPurpose.emailVerification);
    if (entry == null) throw OtpNotFoundError();
    if (entry.isExpired) {
      await _otps.delete(voEmail, OtpPurpose.emailVerification);
      throw OtpExpiredError();
    }
    if (entry.attempts >= 5) {
      await _otps.delete(voEmail, OtpPurpose.emailVerification);
      throw OtpTooManyAttemptsError();
    }

    final hashed = sha256.convert(utf8.encode(voOtp.value)).toString();
    if (hashed != entry.hashedCode) {
      entry.attempts++;
      await _otps.save(entry);
      throw OtpInvalidError();
    }

    // Success
    await _users.update(user.copyWith(status: UserStatus.active));
    await _otps.delete(voEmail, OtpPurpose.emailVerification);
  }
}