import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'dashboard_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool obscure = true;
  bool rememberMe = false;
  bool isLoading = false;

  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    checkLogin();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
    _slide = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(_controller);

    _controller.forward();
  }

  // 🔥 AUTO LOGIN
  void checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogin = prefs.getBool("login") ?? false;

    if (isLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardPage()),
      );
    }
  }

  // 🔐 LOGIN
  void login() async {
    setState(() => isLoading = true);

    bool success = await AuthService.login(
      User(email: email.text, password: password.text),
    );

    setState(() => isLoading = false);

    if (success) {
      if (rememberMe) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("login", true);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login gagal")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F0F0F), Color(0xFF1C1C1C)],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.content_cut, size: 70, color: Colors.amber),

                      SizedBox(height: 20),

                      // 📦 CARD
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFF1C1C1C),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            // EMAIL
                            TextField(
                              controller: email,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: "Email",
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            SizedBox(height: 15),

                            // PASSWORD + 👁️
                            TextField(
                              controller: password,
                              obscureText: obscure,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: "Password",
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscure
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscure = !obscure;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            SizedBox(height: 10),

                            // 💾 REMEMBER ME
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: (val) {
                                    setState(() {
                                      rememberMe = val!;
                                    });
                                  },
                                ),
                                Text(
                                  "Remember Me",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),

                            SizedBox(height: 10),

                            // LOGIN BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                ),
                                child: isLoading
                                    ? CircularProgressIndicator(
                                        color: Colors.black,
                                      )
                                    : Text(
                                        "LOGIN",
                                        style: TextStyle(color: Colors.black),
                                      ),
                              ),
                            ),

                            SizedBox(height: 10),

                            // 🔐 REGISTER LINK
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RegisterPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "Belum punya akun? Daftar",
                                style: TextStyle(color: Colors.amber),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
