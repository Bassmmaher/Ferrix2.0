import '../value_objects/email.dart';
import '../value_objects/otp_code.dart';

abstract class EmailSender {
  Future<void> sendOtp(Email to, OtpCode code);
}