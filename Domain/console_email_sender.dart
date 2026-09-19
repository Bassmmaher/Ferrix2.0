import '../../domain/repositories/email_sender.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/otp_code.dart';

class ConsoleEmailSender implements EmailSender {
  @override
  Future<void> sendOtp(Email to, OtpCode code) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📧 DEV EMAIL → ${to.value}');
    print('🔐 OTP CODE : ${code.value}');
    print('⏱  Expires  : 10 minutes');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}