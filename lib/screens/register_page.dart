import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatelessWidget {
  final email = TextEditingController();
  final password = TextEditingController();

  void register(BuildContext context) async {
    var res = await http.post(
      Uri.parse("http://localhost/barber_api/register.php"),
      body: {"email": email.text, "password": password.text},
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Register berhasil")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(
                hintText: "Email",
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            SizedBox(height: 10),

            TextField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => register(context),
              child: Text("REGISTER"),
            ),
          ],
        ),
      ),
    );
  }
}
