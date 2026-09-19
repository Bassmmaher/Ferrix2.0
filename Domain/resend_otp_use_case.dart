import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../../domain/entities/otp.dart';
import '../../domain/enums/otp_purpose.dart';
import '../../domain/enums/user_status.dart';
import '../../domain/errors/auth_errors.dart';
import '../../domain/repositories/email_sender.dart';
import '../../domain/repositories/otp_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/services/auth_domain_service.dart';
import '../../domain/value_objects/email.dart';

class ResendOtpUseCase {
  final UserRepository _users;
  final OtpRepository _otps;
  final EmailSender _emails;
  final AuthDomainService _domain;

  ResendOtpUseCase({
    required UserRepository users,
    required OtpRepository otps,
    required EmailSender emails,
    required AuthDomainService domain,
  })  : _users = users,
        _otps = otps,
        _emails = emails,
        _domain = domain;

  Future<void> call({required String email}) async {
    final voEmail = Email(email);

    final user = await _users.findByEmail(voEmail);
    if (user == null) throw UserNotFoundError();
    if (user.status == UserStatus.active) {
      throw ValidationError('Account already verified');
    }

    // Delete old + create new
    await _otps.delete(voEmail, OtpPurpose.emailVerification);
    final code = _domain.generateOtp();
    final hashed = sha256.convert(utf8.encode(code.value)).toString();

    await _otps.save(Otp(
      email: voEmail,
      hashedCode: hashed,
      purpose: OtpPurpose.emailVerification,
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
    ));

    await _emails.sendOtp(voEmail, code);
  }
}