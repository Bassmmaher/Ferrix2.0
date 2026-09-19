import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/otp.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/otp_purpose.dart';
import '../../domain/enums/user_status.dart';
import '../../domain/errors/auth_errors.dart';
import '../../domain/repositories/email_sender.dart';
import '../../domain/repositories/otp_repository.dart';
import '../../domain/repositories/password_hasher.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/services/auth_domain_service.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/full_name.dart';
import '../../domain/value_objects/password.dart';
import '../../domain/value_objects/user_id.dart';

class SignUpUseCase {
  final UserRepository _users;
  final OtpRepository _otps;
  final PasswordHasher _hasher;
  final EmailSender _emails;
  final AuthDomainService _domain;

  SignUpUseCase({
    required UserRepository users,
    required OtpRepository otps,
    required PasswordHasher hasher,
    required EmailSender emails,
    required AuthDomainService domain,
  })  : _users = users,
        _otps = otps,
        _hasher = hasher,
        _emails = emails,
        _domain = domain;

  Future<void> call({
    required String name,
    required String email,
    required String password,
  }) async {
    // 1. Validate value objects (throws ValidationError)
    final voName = FullName(name);
    final voEmail = Email(email);
    final voPassword = RawPassword(password);

    // 2. Uniqueness
    final existing = await _users.findByEmail(voEmail);
    if (existing != null) throw EmailAlreadyExistsError();

    // 3. Build user
    final user = User(
      id: UserId(const Uuid().v4()),
      name: voName,
      email: voEmail,
      passwordHash: _hasher.hash(voPassword),
      status: UserStatus.pending,
      createdAt: DateTime.now(),
    );
    await _users.save(user);

    // 4. OTP
    final code = _domain.generateOtp();
    final hashed = sha256.convert(utf8.encode(code.value)).toString();

    await _otps.save(Otp(
      email: voEmail,
      hashedCode: hashed,
      purpose: OtpPurpose.emailVerification,
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
    ));

    // 5. Send
    await _emails.sendOtp(voEmail, code);
  }
}