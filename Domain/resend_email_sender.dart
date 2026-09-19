import '../../domain/repositories/email_sender.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/otp_code.dart';

/// Replace ConsoleEmailSender with this once you have a real API key.
class ResendEmailSender implements EmailSender {
  final String apiKey;
  ResendEmailSender({required this.apiKey});

  @override
  Future<void> sendOtp(Email to, OtpCode code) async {
    // TODO: POST to https://api.resend.com/emails
    throw UnimplementedError('Configure Resend before using in production');
  }
}