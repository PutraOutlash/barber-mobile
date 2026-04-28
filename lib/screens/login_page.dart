import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'main_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 🔥 WARNA GOLD PREMIUM
  static const Color goldAccent = Color(0xFFD4AF67);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkInput = Color(0xFF1A1A1A);

  // Controller untuk input (Bisa diisi Username ATAU Email)
  TextEditingController identifierController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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

    if (isLogin && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    }
  }

  // 🔐 LOGIN FIX & SIMPAN DATA USER
  void login() async {
    // Validasi kosong
    if (identifierController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username/Email dan Password harus diisi!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    // Kirim input ke AuthService (bisa berupa username atau email)
    var result = await AuthService.login(
      identifierController.text,
      passwordController.text,
    );

    if (mounted) {
      setState(() => isLoading = false);
    }

    print("DEBUG LOGIN: $result");

    if (result['status'] == 'success') {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // 1. Simpan Status Login (Jika Remember Me dicentang)
      if (rememberMe) {
        prefs.setBool("login", true);
      } else {
        // Tetap simpan sesi sementara (bisa diatur sesuai kebutuhan aplikasimu)
        prefs.setBool("login", true);
      }

      // 2. Simpan Data User (Kartu ID) dari database ke memori HP
      var userData = result['data'];
      prefs.setString("user_id", userData['id'].toString());

      // 🔥 PASTIKAN MENANGKAP 'username' (bukan 'name' lagi)
      prefs.setString("user_name", userData['username'].toString());
      prefs.setString("user_email", userData['email'].toString());

      // Jika alamat null di database, kasih teks default
      if (userData['address'] != null) {
        prefs.setString("user_address", userData['address'].toString());
      } else {
        prefs.setString("user_address", "Belum diatur");
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Login gagal"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- LOGO & HEADER ---
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: goldAccent.withOpacity(0.08),
                      border: Border.all(
                        color: goldAccent.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.content_cut,
                      size: 60,
                      color: goldAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                const Text(
                  "WELCOME BACK",
                  style: TextStyle(
                    color: goldAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Log in to your account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 40),

                // --- USERNAME / EMAIL INPUT ---
                TextField(
                  controller: identifierController,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: _customInputDecoration(
                    hintText: "Username atau Email",
                    icon: Icons.person_outline, // Ikon ganti jadi orang
                  ),
                ),
                const SizedBox(height: 20),

                // --- PASSWORD INPUT ---
                TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: _customInputDecoration(
                    hintText: "Password",
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white38,
                      ),
                      onPressed: () {
                        setState(() {
                          obscure = !obscure;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // --- REMEMBER ME & FORGOT PASSWORD ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: rememberMe,
                            activeColor: goldAccent,
                            checkColor: Colors.black,
                            side: const BorderSide(color: Colors.white24),
                            onChanged: (val) {
                              setState(() {
                                rememberMe = val!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Remember Me",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                    const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: goldAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // --- LOGIN BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: goldAccent.withOpacity(0.4),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            "LOGIN NOW",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- REGISTER LINK ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: goldAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET BANTUAN UNTUK DEKORASI INPUT ---
  InputDecoration _customInputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
      filled: true,
      fillColor: darkInput,
      prefixIcon: Icon(icon, color: Colors.white54, size: 22),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: goldAccent, width: 2),
      ),
    );
  }
}
