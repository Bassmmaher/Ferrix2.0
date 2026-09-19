import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'package:auth_backend/controllers/auth_controller.dart';
import 'package:auth_backend/middleware/auth_middleware.dart';

void main() async {
  final auth = AuthController();
  final router = Router();

  // Public routes
  router.post('/auth/signup', auth.signup);
  router.post('/auth/verify', auth.verify);
  router.post('/auth/resend-otp', auth.resendOtp);
  router.post('/auth/login', auth.login);

  // Protected example route
  router.get('/me', (Request req) {
    final userId = req.context['userId'];
    return Response.ok('{"userId":"$userId"}');
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware())
      .addHandler(router.call);

  // Mount the protected route behind authMiddleware separately
  final protectedHandler = Pipeline()
      .addMiddleware(authMiddleware())
      .addHandler(router.call);

  final server = await io.serve(
    Cascade()
        .add(handler)
        .add(protectedHandler)
        .handler,
    InternetAddress.anyIPv4,
    8080,
  );

  print('🚀 Server running on http://${server.address.host}:${server.port}');
}

Middleware _corsMiddleware() {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
  };
  return (Handler inner) {
    return (Request req) async {
      if (req.method == 'OPTIONS') return Response.ok('', headers: headers);
      final res = await inner(req);
      return res.change(headers: headers);
    };
  };
}
