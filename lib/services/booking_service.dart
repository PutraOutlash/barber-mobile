import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'dart:convert';
import 'dart:io';

class BookingService {
  static Future<Map<String, dynamic>> createBooking({
    required String userId,
    required String serviceId,
    required String barberId,
    String? hairstyleId, // Bisa null jika pakai foto custom
    File? imageFile, // File foto custom
    required String date,
    required String startTime,
    required String endTime,
    required String totalPrice,
  }) async {
    try {
      // Gunakan MultipartRequest untuk mendukung pengiriman File
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Api.baseUrl}/booking/create.php'),
      );

      // Masukkan data teks
      request.fields['user_id'] = userId;
      request.fields['service_id'] = serviceId;
      request.fields['barber_id'] = barberId;
      if (hairstyleId != null) request.fields['hairstyle_id'] = hairstyleId;
      request.fields['date'] = date;
      request.fields['start_time'] = startTime;
      request.fields['end_time'] = endTime;
      request.fields['total_price'] = totalPrice;

      // Masukkan data file (jika ada)
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', imageFile.path),
        );
      }

      // Kirim ke server
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return jsonDecode(response.body);
    } catch (e) {
      print("ERROR BOOKING: $e");
      return {"status": "error", "message": "Gagal terhubung ke server"};
    }
  }
}
