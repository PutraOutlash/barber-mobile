import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/user_model.dart';

class AuthService {
  static Future<bool> login(User user) async {
    var response = await http.post(
      Uri.parse("${Api.baseUrl}login.php"),
      body: user.toJson(),
    );

    var data = jsonDecode(response.body);

    return data["status"] == "success";
  }
}
