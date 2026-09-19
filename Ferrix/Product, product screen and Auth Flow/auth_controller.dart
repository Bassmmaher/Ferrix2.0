import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

import '../services/user_service.dart';
import '../services/otp_service.dart';
import '../services/email_service.dart';
import '../services/jwt_service.dart';
import '../utils/validators.dart';

class AuthController {
  final _users = UserService();
  final _otps = OtpService();
  final _emails = EmailService();
  final _jwt = JwtService();

  // ─────────────────────────────────────────────
  // POST /auth/signup
  // ─────────────────────────────────────────────
  Future<Response> signup(Request request) async {
    final body = await _readJson(request);
    if (body == null) return _badRequest('Invalid JSON body');

    final name = (body['name'] as String?)?.trim();
    final email = (body['email'] as String?)?.trim();
    final password = body['password'] as String?;

    if (name == null || name.isEmpty) return _badRequest('Name is required');
    if (email == null || !isValidEmail(email)) {
      return _badRequest('Valid email is required');
    }
    if (password == null) return _badRequest('Password is required');
    final pwErr = validatePassword(password);
    if (pwErr != null) return _badRequest(pwErr);

    // Check if user already exists
    final existing = await _users.findByEmail(email);
    if (existing != null) {
      return _json(409, {'error': 'Email already registered'});
    }

    // Create user (unverified)
    await _users.create(
      id: const Uuid().v4(),
      name: name,
      email: email,
      plainPassword: password,
    );

    // Generate OTP + send email (console in dev)
    final otp = _otps.generate(email);
    await _emails.sendOtp(email, otp);

    return _json(200, {
      'message': 'Signup successful. Check your email for the OTP.',
    });
  }

  // ─────────────────────────────────────────────
  // POST /auth/verify
  // ─────────────────────────────────────────────
  Future<Response> verify(Request request) async {
    final body = await _readJson(request);
    if (body == null) return _badRequest('Invalid JSON body');

    final email = (body['email'] as String?)?.trim();
    final otp = (body['otp'] as String?)?.trim();

    if (email == null || otp == null) {
      return _badRequest('Email and OTP are required');
    }

    final user = await _users.findByEmail(email);
    if (user == null) return _json(404, {'error': 'User not found'});

    if (user.isVerified) {
      return _json(400, {'error': 'Already verified'});
    }

    final result = _otps.verify(email, otp);
    switch (result) {
      case 'ok':
        await _users.markVerified(email);
        return _json(200, {
          'message': 'Email verified successfully',
          'user': user.toSafeJson(),
        });
      case 'expired':
        return _json(400, {'error': 'OTP expired. Please request a new one.'});
      case 'invalid':
        return _json(400, {'error': 'Invalid OTP'});
      case 'too_many_attempts':
        return _json(429, {'error': 'Too many attempts. Request a new OTP.'});
      case 'not_found':
      default:
        return _json(400, {'error': 'No OTP found. Request a new one.'});
    }
  }

  // ─────────────────────────────────────────────
  // POST /auth/resend-otp
  // ─────────────────────────────────────────────
  Future<Response> resendOtp(Request request) async {
    final body = await _readJson(request);
    if (body == null) return _badRequest('Invalid JSON body');

    final email = (body['email'] as String?)?.trim();
    if (email == null) return _badRequest('Email is required');

    final user = await _users.findByEmail(email);
    if (user == null) return _json(404, {'error': 'User not found'});
    if (user.isVerified) return _json(400, {'error': 'Already verified'});

    final otp = _otps.generate(email);
    await _emails.sendOtp(email, otp);

    return _json(200, {'message': 'New OTP sent'});
  }

  // ─────────────────────────────────────────────
  // POST /auth/login
  // ─────────────────────────────────────────────
  Future<Response> login(Request request) async {
    final body = await _readJson(request);
    if (body == null) return _badRequest('Invalid JSON body');

    final email = (body['email'] as String?)?.trim();
    final password = body['password'] as String?;

    if (email == null || password == null) {
      return _badRequest('Email and password are required');
    }

    final user = await _users.findByEmail(email);

    // Never reveal whether the email exists.
    if (user == null || !_users.verifyPassword(password, user.passwordHash)) {
      return _json(401, {'error': 'Invalid email or password'});
    }

    if (!user.isVerified) {
      return _json(403, {
        'error': 'Email not verified. Please verify first.',
        'needsVerification': true,
      });
    }

    final accessToken = _jwt.generateAccessToken(user.id);
    final refreshToken = _jwt.generateRefreshToken(user.id);

    return _json(200, {
      'message': 'Login successful',
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toSafeJson(),
    });
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
  Future<Map<String, dynamic>?> _readJson(Request request) async {
    try {
      final raw = await request.readAsString();
      if (raw.isEmpty) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Response _json(int status, Map<String, dynamic> body) => Response(
        status,
        body: jsonEncode(body),
        headers: {'content-type': 'application/json'},
      );

  Response _badRequest(String msg) => _json(400, {'error': msg});
}
