import 'package:shelf/shelf.dart';
import '../services/jwt_service.dart';

Middleware authMiddleware() {
  final jwt = JwtService();
  return (Handler innerHandler) {
    return (Request request) async {
      final header = request.headers['authorization'];
      if (header == null || !header.startsWith('Bearer ')) {
        return Response(401, body: '{"error":"Missing token"}');
      }

      final token = header.substring(7);
      final userId = jwt.verifyAccessToken(token);
      if (userId == null) {
        return Response(401, body: '{"error":"Invalid or expired token"}');
      }

      final updated = request.change(context: {'userId': userId});
      return innerHandler(updated);
    };
  };
}
