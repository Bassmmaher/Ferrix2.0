import '../errors/auth_errors.dart';

class OtpCode {
  final String value;
  OtpCode._(this.value);

  factory OtpCode(String raw) {
    if (!RegExp(r'^\d{6}$').hasMatch(raw)) {
      throw ValidationError('OTP must be exactly 6 digits');
    }
    return OtpCode._(raw);
  }

  /// Used by the OTP generator — does not validate input format.
  factory OtpCode.generated(String raw) => OtpCode._(raw);

  @override
  String toString() => value;
}