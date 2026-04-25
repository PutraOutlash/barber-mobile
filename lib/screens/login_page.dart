import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'main_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key}); // Tambahkan const dan super.key

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool obscure = true;
  bool rememberMe = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  // 🔥 AUTO LOGIN
  void checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogin = prefs.getBool("login") ?? false;

    // Tambahkan pengecekan mounted sebelum pindah halaman
    if (isLogin && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    }
  }

  // 🔐 LOGIN FIX
  void login() async {
    setState(() => isLoading = true);

    var result = await AuthService.login(email.text, password.text);

    if (mounted) {
      setState(() => isLoading = false);
    }

    print(result); // 🔥 DEBUG

    if (result['status'] == 'success') {
      if (rememberMe) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("login", true);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login gagal")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.content_cut, size: 70, color: Colors.amber),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // EMAIL
                    TextField(
                      controller: email,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Email",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // PASSWORD
                    TextField(
                      controller: password,
                      obscureText: obscure,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Password",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure ? Icons.visibility : Icons.visibility_off,
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

                    const SizedBox(height: 10),

                    // REMEMBER ME
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
                        const Text(
                          "Remember Me",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : const Text(
                                "LOGIN",
                                style: TextStyle(color: Colors.black),
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // REGISTER
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterPage()),
                        );
                      },
                      child: const Text(
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
    );
  }
}
