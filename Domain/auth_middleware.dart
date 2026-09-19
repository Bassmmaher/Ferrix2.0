import 'package:shelf/shelf.dart';
import '../../domain/repositories/token_service.dart';

Middleware authMiddleware(TokenService tokens) {
  return (Handler inner) => (Request req) async {
        final header = req.headers['authorization'];
        if (header == null || !header.startsWith('Bearer ')) {
          return Response(401,
              body: '{"error":"Missing token"}',
              headers: {'content-type': 'application/json'});
        }
        final userId = tokens.verifyAccess(header.substring(7));
        if (userId == null) {
          return Response(401,
              body: '{"error":"Invalid token"}',
              headers: {'content-type': 'application/json'});
        }
        return inner(req.change(context: {'userId': userId.value}));
      };
}