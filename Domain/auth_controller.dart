import 'dart:convert';
import 'package:shelf/shelf.dart';

import '../../application/use_cases/login_use_case.dart';
import '../../application/use_cases/resend_otp_use_case.dart';
import '../../application/use_cases/sign_up_use_case.dart';
import '../../application/use_cases/verify_email_use_case.dart';
import '../../domain/errors/auth_errors.dart';

class AuthController {
  final SignUpUseCase _signUp;
  final VerifyEmailUseCase _verify;
  final ResendOtpUseCase _resend;
  final LoginUseCase _login;

  AuthController({
    required SignUpUseCase signUp,
    required VerifyEmailUseCase verify,
    required ResendOtpUseCase resend,
    required LoginUseCase login,
  })  : _signUp = signUp,
        _verify = verify,
        _resend = resend,
        _login = login;

  Future<Response> signup(Request req) => _handle(() async {
        final b = await _body(req);
        await _signUp(
          name: b['name'],
          email: b['email'],
          password: b['password'],
        );
        return _json(200, {'message': 'Signup successful. Check your email.'});
      });

  Future<Response> verify(Request req) => _handle(() async {
        final b = await _body(req);
        await _verify(email: b['email'], otp: b['otp']);
        return _json(200, {'message': 'Email verified. You can log in now.'});
      });

  Future<Response> resend(Request req) => _handle(() async {
        final b = await _body(req);
        await _resend(email: b['email']);
        return _json(200, {'message': 'New OTP sent'});
      });

  Future<Response> login(Request req) => _handle(() async {
        final b = await _body(req);
        final result = await _login(
          email: b['email'],
          password: b['password'],
        );
        return _json(200, {
          'message': 'Login successful',
          'accessToken': result.accessToken,
          'refreshToken': result.refreshToken,
          'user': {
            'id': result.user.id,
            'name': result.user.name,
            'email': result.user.email,
            'status': result.user.status,
          },
        });
      });

  // ─────────── Helpers ───────────

  Future<Map<String, dynamic>> _body(Request req) async {
    final raw = await req.readAsString();
    if (raw.isEmpty) throw ValidationError('Empty request body');
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<Response> _handle(Future<Response> Function() fn) async {
    try {
      return await fn();
    } on ValidationError catch (e) {
      return _json(400, {'error': e.message});
    } on EmailAlreadyExistsError catch (e) {
      return _json(409, {'error': e.message});
    } on InvalidCredentialsError catch (e) {
      return _json(401, {'error': e.message});
    } on UserNotVerifiedError catch (e) {
      return _json(403, {'error': e.message, 'needsVerification': true});
    } on OtpExpiredError catch (e) {
      return _json(400, {'error': e.message});
    } on OtpInvalidError catch (e) {
      return _json(400, {'error': e.message});
    } on OtpTooManyAttemptsError catch (e) {
      return _json(429, {'error': e.message});
    } on OtpNotFoundError catch (e) {
      return _json(400, {'error': e.message});
    } on UserNotFoundError catch (e) {
      return _json(404, {'error': e.message});
    } on AuthError catch (e) {
      return _json(400, {'error': e.message});
    } catch (e) {
      // ignore: avoid_print
      print('❌ Unhandled: $e');
      return _json(500, {'error': 'Internal server error'});
    }
  }

  Response _json(int status, Map<String, dynamic> body) => Response(
        status,
        body: jsonEncode(body),
        headers: {'content-type': 'application/json'},
      );
}