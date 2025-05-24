import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Custom CORS middleware
Middleware corsHeaders() {
  return createMiddleware(
    requestHandler: (Request request) {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Requested-With, Accept, Authorization',
        });
      }
      return null;
    },
    responseHandler: (Response response) {
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Requested-With, Accept, Authorization',
      });
    },
  );
}

void main(List<String> args) async {
  // 1) Define your routes
  final router = Router()
    ..get('/ping', (Request req) => Response.ok('pong'))
    ..get('/todos', (Request req) {
      final todos = [
        {'id': 1, 'task': 'Buy coffee'},
        {'id': 2, 'task': 'Learn Dart backend'},
      ];
      return Response.ok(
        jsonEncode(todos), // Use proper JSON encoding
        headers: {'Content-Type': 'application/json'},
      );
    });

  // 2) Configure middleware (CORS, logging, etc.)
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router);

  // 3) Start the server
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, '0.0.0.0', port);
  print('🚀 Dart server running on http://${server.address.host}:${server.port}');
}