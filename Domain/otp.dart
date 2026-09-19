import 'email.dart';
import 'otp_purpose.dart';

class Otp {
  final Email email;
  final String hashedCode;
  final OtpPurpose purpose;
  final DateTime expiresAt;
  int attempts;

  Otp({
    required this.email,
    required this.hashedCode,
    required this.purpose,
    required this.expiresAt,
    this.attempts = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}