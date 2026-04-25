import 'package:flutter/material.dart';
import 'package:barber_app/screens/login_page.dart'; // Import halaman login

// PINTU MASUK UTAMA FLUTTER
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barber App',
      // Setelah aplikasi buka, arahkan langsung ke halaman Login
      home: const LoginPage(),
    );
  }
}
