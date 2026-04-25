import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class HairstyleService {
  static Future<List<dynamic>> getHairstyles() async {
    var res = await http.get(Uri.parse("${Api.baseUrl}/hairstyle/get.php"));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Gagal memuat gaya rambut");
    }
  }
}
