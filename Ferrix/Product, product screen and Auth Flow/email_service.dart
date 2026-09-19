import 'dart:io';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  Future<void> sendOtp(String email, String otp) async {
    final env = Platform.environment['APP_ENV'] ?? 'development';

    if (env == 'development') {
      // 🔐 DEV ONLY: print OTP to terminal so we can test the flow
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📧 DEV EMAIL → $email');
      print('🔐 OTP CODE : $otp');
      print('⏱  Expires  : 10 minutes');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return;
    }

    // TODO: production email (Resend, SendGrid, SMTP)
    // final response = await http.post(
    //   Uri.parse('https://api.resend.com/emails'),
    //   headers: {'Authorization': 'Bearer $apiKey'},
    //   body: jsonEncode({...}),
    // );
    throw UnimplementedError('Production email not configured yet');
  }
}
