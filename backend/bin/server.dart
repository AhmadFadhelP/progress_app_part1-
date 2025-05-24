// backend/bin/server.dart
import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart' as fb_admin;

// Fungsi untuk inisialisasi Firebase Admin
Future<void> initializeFirebaseAdmin() async {
  // Path ke file service account key Anda
  // Idealnya, gunakan environment variable untuk path ini di production
  final serviceAccountKeyPath = Platform.environment['FIREBASE_SERVICE_ACCOUNT_KEY_PATH'] ?? 'serviceAccountKey.json';
  final serviceAccountFile = File(serviceAccountKeyPath);

  if (!await serviceAccountFile.exists()) {
    print('Error: File service account key tidak ditemukan di $serviceAccountKeyPath');
    print('Pastikan Anda sudah mengunduhnya dari Firebase Console dan menyimpannya dengan benar.');
    print('Atau set environment variable FIREBASE_SERVICE_ACCOUNT_KEY_PATH');
    exit(1); // Keluar jika file tidak ditemukan
  }

  try {
    final serviceAccountCredentials = fb_admin.ServiceAccountCredentials.fromFile(serviceAccountFile);
    final appName = 'dart-backend-${DateTime.now().millisecondsSinceEpoch}'; // Nama unik untuk instance app

    // Periksa apakah aplikasi dengan nama default sudah diinisialisasi
    try {
      fb_admin.FirebaseAdmin.instance.app();
    } catch (e) {
      // Jika belum, inisialisasi aplikasi default
      fb_admin.FirebaseAdmin.instance.initializeApp(
        fb_admin.AppOptions(
          credential: serviceAccountCredentials,
          // Anda mungkin perlu projectId jika tidak ada di service account key
          // projectId: 'YOUR_FIREBASE_PROJECT_ID',
        ),
        appName, // Berikan nama unik jika menginisialisasi beberapa kali (misalnya dalam hot reload)
      );
      print('Firebase Admin SDK diinisialisasi.');
    }


  } catch (e) {
    print('Error saat inisialisasi Firebase Admin SDK: $e');
    exit(1);
  }
}

// Middleware untuk verifikasi Firebase ID Token
shelf.Middleware firebaseAuthMiddleware() {
  return (shelf.Handler innerHandler) {
    return (shelf.Request request) async {
      final authHeader = request.headers['authorization'];
      String? idToken;

      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        idToken = authHeader.substring(7); // Ambil token setelah "Bearer "
      }

      if (idToken == null) {
        return shelf.Response.forbidden('Authorization token not found.');
      }

      try {
        // Verifikasi token
        final decodedToken = await fb_admin.FirebaseAdmin.instance
            .auth()
            .verifyIdToken(idToken);
        // Tambahkan user_id (UID Firebase) ke konteks request jika valid
        final updatedRequest = request.change(context: {
          ...request.context,
          'user_id': decodedToken.uid,
          'email': decodedToken.email, // Anda juga bisa mendapatkan email, dll.
        });
        print('Token valid untuk user: ${decodedToken.uid}');
        return await innerHandler(updatedRequest);
      } on fb_admin.FirebaseAuthException catch (e) {
        print('Firebase Auth Exception: ${e.code} - ${e.message}');
        return shelf.Response.unauthorized('Invalid or expired token.');
      } catch (e) {
        print('Error verifikasi token: $e');
        return shelf.Response.internalServerError(body: 'Token verification error.');
      }
    };
  };
}

void main(List<String> args) async {
  // Inisialisasi Firebase Admin
  await initializeFirebaseAdmin();

  final app = Router();

  app.get('/hello', (shelf.Request request) {
    return shelf.Response.ok('Hello, World!');
  });

  // Endpoint yang memerlukan autentikasi
  app.get('/api/iot-data', (shelf.Request request) {
    final userId = request.context['user_id'] as String?;
    if (userId == null) {
      // Ini seharusnya tidak terjadi jika middleware bekerja dengan benar
      return shelf.Response.internalServerError(body: 'User ID not found in context.');
    }
    // Sekarang Anda bisa menggunakan userId untuk mengambil data IoT spesifik pengguna
    return shelf.Response.ok('Data IoT untuk pengguna: $userId');
  });

  // Gabungkan middleware dengan router
  final cascade = shelf.Cascade()
      .add(app.call) // Untuk rute tanpa auth (jika ada)
      .add(firebaseAuthMiddleware()(app.call)) // Terapkan middleware ke semua rute di 'app'
      .handler;

  // Atau jika ingin menerapkan middleware hanya pada rute tertentu:
  final mainPipeline = const shelf.Pipeline()
      // .addMiddleware(shelf.logRequests()) // Middleware lain jika perlu
      .addMiddleware(firebaseAuthMiddleware()) // Terapkan ke handler setelah ini
      .addHandler(app.call);


  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(mainPipeline, 'localhost', port); // Atau app.call jika tidak pakai mainPipeline
  print('Server backend berjalan di http://${server.address.host}:${server.port}');
}