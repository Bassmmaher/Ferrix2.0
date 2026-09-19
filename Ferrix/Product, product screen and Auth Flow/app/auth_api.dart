import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthApi {
  // Android emulator → 10.0.2.2, iOS simulator → localhost
  static const String baseUrl = 'http://10.0.2.2:8080';
  static const _storage = FlutterSecureStorage();

  // ─────────── Sign Up ───────────
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return _handle(res);
  }

  // ─────────── Verify OTP ───────────
  static Future<Map<String, dynamic>> verify({
    required String email,
    required String otp,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    return _handle(res);
  }

  // ─────────── Resend OTP ───────────
  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/resend-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return _handle(res);
  }

  // ─────────── Login ───────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = _handle(res);
    if (res.statusCode == 200) {
      await _storage.write(key: 'accessToken', value: data['accessToken']);
      await _storage.write(key: 'refreshToken', value: data['refreshToken']);
    }
    return data;
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  static Future<String?> getAccessToken() =>
      _storage.read(key: 'accessToken');

  // ─────────── Helpers ───────────
  static Map<String, dynamic> _handle(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw Exception(body['error'] ?? 'Request failed');
  }
}
