// lib/service/api_service.dart (di Flutter)
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // Impor auth service Anda

class ApiService {
  final String baseUrl = 'http://localhost:8080'; // URL backend Anda
  final AuthService _authService = AuthService();

  Future<void> fetchIoTData() async {
    String? token = await _authService.getCurrentUserToken();

    if (token == null) {
      print('Pengguna belum login, tidak bisa mengambil data IoT.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/iot-data'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // KIRIM TOKEN DI SINI!
        },
      );

      if (response.statusCode == 200) {
        print('Data IoT diterima: ${response.body}');
        // Proses data
      } else {
        print('Gagal mengambil data IoT: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error saat request ke backend: $e');
    }
  }
}