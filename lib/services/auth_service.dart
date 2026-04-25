import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      // 🔥 Perbaikan: Menambahkan '/auth/' karena login.php sudah dipindah
      var res = await http.post(
        Uri.parse("${Api.baseUrl}/auth/login.php"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"email": email, "password": password},
      );

      print("STATUS: ${res.statusCode}"); // 🔥 DEBUG
      print("RESPONSE: ${res.body}"); // 🔥 DEBUG

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return {
          "status": "failed",
          "message": "Terjadi kesalahan server: ${res.statusCode}",
        };
      }
    } catch (e) {
      // Menangkap error jika XAMPP mati atau tidak ada koneksi
      print("ERROR: $e");
      return {
        "status": "failed",
        "message": "Gagal terhubung ke server. Pastikan XAMPP menyala.",
      };
    }
  }
}
