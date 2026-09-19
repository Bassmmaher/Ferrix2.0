import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class _OtpEntry {
  final String hashedOtp;
  final DateTime expiresAt;
  int attempts;
  _OtpEntry(this.hashedOtp, this.expiresAt) : attempts = 0;
}

/// In-memory OTP store.
/// Replace with Redis later — interface stays the same.
class OtpService {
  static final OtpService _instance = OtpService._internal();
  factory OtpService() => _instance;
  OtpService._internal();

  final Map<String, _OtpEntry> _store = {};

  static const int _otpLength = 6;
  static const Duration _ttl = Duration(minutes: 10);
  static const int _maxAttempts = 5;

  /// Returns the plain OTP so we can send it via email/log.
  String generate(String email) {
    final random = Random.secure();
    final otp =
        List.generate(_otpLength, (_) => random.nextInt(10)).join();

    _store[email.toLowerCase()] = _OtpEntry(
      _hash(otp),
      DateTime.now().add(_ttl),
    );
    return otp;
  }

  /// Returns: 'ok' | 'expired' | 'invalid' | 'too_many_attempts' | 'not_found'
  String verify(String email, String otp) {
    final key = email.toLowerCase();
    final entry = _store[key];
    if (entry == null) return 'not_found';

    if (DateTime.now().isAfter(entry.expiresAt)) {
      _store.remove(key);
      return 'expired';
    }

    if (entry.attempts >= _maxAttempts) {
      _store.remove(key);
      return 'too_many_attempts';
    }

    if (_hash(otp) != entry.hashedOtp) {
      entry.attempts++;
      return 'invalid';
    }

    _store.remove(key);
    return 'ok';
  }

  String _hash(String value) =>
      sha256.convert(utf8.encode(value)).toString();
}
