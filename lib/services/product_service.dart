import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class ProductService {
  static Future<List<dynamic>> getProducts() async {
    var res = await http.get(Uri.parse("${Api.baseUrl}/product/get.php"));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Gagal memuat produk");
    }
  }
}
