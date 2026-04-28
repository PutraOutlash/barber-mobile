import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../services/auth_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- STATE VARIABLES ---
  File? _profileImage;

  // Nilai default awal (akan tertimpa oleh data dari database)
  String userName = "Memuat...";
  String userEmail = "Memuat...";
  String userPhone = "-";
  String userAddress = "-";

  bool isDarkMode = true; // Untuk pengaturan tema lokal

  static const Color goldAccent = Color(0xFFD4AF67);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 🔥 Panggil data asli saat halaman dibuka
  }

  // --- FUNGSI LOAD DATA DARI MEMORI HP ---
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("user_name") ?? "User Tanpa Nama";
      userEmail = prefs.getString("user_email") ?? "email@belum.diatur";
      userPhone = prefs.getString("user_phone") ?? "Belum diatur";
      userAddress = prefs.getString("user_address") ?? "Belum diatur";
    });
  }

  // --- FUNGSI UPLOAD FOTO PROFIL ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
      // Nanti di sini bisa ditambahkan logika menembak API upload_photo.php
    }
  }

  // --- FUNGSI LOGOUT AKTIF ---
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Menghapus semua sesi login

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : Colors.white,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? darkBackground : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 🔥 PROFILE HEADER DENGAN FITUR UPLOAD
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: goldAccent.withOpacity(0.2),
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? const Icon(Icons.person, size: 50, color: goldAccent)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: goldAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: darkBackground, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Column(
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 🔥 INFO CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _boxDecoration(),
            child: Column(
              children: [
                _profileItem(Icons.phone, "Nomor", userPhone),
                _divider(),
                _profileItem(Icons.location_on, "Alamat", userAddress),
                _divider(),
                _profileItem(Icons.card_membership, "Member", "Premium"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 MENU OPTIONS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _boxDecoration(),
            child: Column(
              children: [
                _menuItem(
                  Icons.edit,
                  "Edit Profile",
                  onTap: _showEditProfileDialog,
                ),
                _divider(),
                _menuItem(
                  Icons.lock_outline,
                  "Ubah Password (OTP)",
                  onTap: _showOTPPasswordDialog,
                ),
                _divider(),
                _menuItem(
                  Icons.palette_outlined,
                  "Pengaturan Tema",
                  onTap: _showSettingsDialog,
                ),
                _divider(),
                _menuItem(
                  Icons.help_outline,
                  "Bantuan & Kontak",
                  onTap: _showHelpDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 🔴 TOMBOL LOGOUT BERFUNGSI
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.redAccent),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text(
              "LOGOUT",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: darkCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: const Text(
                    "Konfirmasi Logout",
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    "Apakah Anda yakin ingin keluar dari akun?",
                    style: TextStyle(color: Colors.grey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Batal",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Tutup dialog
                        _logout(); // Eksekusi fungsi logout
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- WIDGET BANTUAN ---

  Widget _profileItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: goldAccent, size: 20),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: goldAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: goldAccent, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(
        color: isDarkMode ? Colors.white10 : Colors.black12,
        thickness: 1,
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: isDarkMode ? darkCard : Colors.grey[100],
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDarkMode ? Colors.white10 : Colors.transparent,
      ),
    );
  }

  // --- DIALOG MODALS UNTUK FITUR BARU ---

  // 1. Edit Profile
  void _showEditProfileDialog() {
    TextEditingController nameController = TextEditingController(
      text: userName,
    );
    TextEditingController phoneController = TextEditingController(
      text: userPhone,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: darkCard,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nama",
                labelStyle: TextStyle(color: goldAccent),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nomor Telepon",
                labelStyle: TextStyle(color: goldAccent),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: goldAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              // Update state di layar
              setState(() {
                userName = nameController.text;
                userPhone = phoneController.text;
              });

              // Simpan sementara ke memori HP
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString("user_name", nameController.text);
              prefs.setString("user_phone", phoneController.text);

              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // 2. Ubah Password dengan OTP (Dinams)
  void _showOTPPasswordDialog() {
    TextEditingController otpController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    bool isOtpSent = false;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: darkCard,
            title: const Text(
              "Ubah Password",
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isOtpSent
                      ? "OTP telah dikirim ke $userEmail. Silakan cek kotak masuk atau folder spam."
                      : "Klik tombol di bawah untuk mengirim kode OTP 6-digit ke email: $userEmail",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 15),

                if (isOtpSent) ...[
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Masukkan 6 Digit OTP",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: darkBackground,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Password Baru",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: darkBackground,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldAccent,
                  foregroundColor: Colors.black,
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        setDialogState(() => isLoading = true);

                        if (!isOtpSent) {
                          var res = await AuthService.sendOtp(userEmail);
                          setDialogState(() => isLoading = false);

                          if (res['status'] == 'success') {
                            setDialogState(() => isOtpSent = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("OTP Terkirim! Cek email Anda."),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  res['message'] ?? "Gagal kirim OTP",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          if (otpController.text.isEmpty ||
                              newPasswordController.text.isEmpty) {
                            setDialogState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Isi OTP dan Password Baru!"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          var res = await AuthService.verifyAndChangePassword(
                            userEmail,
                            otpController.text,
                            newPasswordController.text,
                          );
                          setDialogState(() => isLoading = false);

                          if (res['status'] == 'success') {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Password berhasil diubah!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  res['message'] ?? "Verifikasi gagal",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(isOtpSent ? "Konfirmasi" : "Kirim OTP"),
              ),
            ],
          );
        },
      ),
    );
  }

  // 3. Pengaturan Tema
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: darkCard,
            title: const Text(
              "Pengaturan",
              style: TextStyle(color: Colors.white),
            ),
            content: SwitchListTile(
              title: const Text(
                "Tema Gelap",
                style: TextStyle(color: Colors.white),
              ),
              activeColor: goldAccent,
              value: isDarkMode,
              onChanged: (val) {
                setDialogState(() => isDarkMode = val);
                setState(() => isDarkMode = val); // Update UI halaman profil
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Tutup", style: TextStyle(color: goldAccent)),
              ),
            ],
          );
        },
      ),
    );
  }

  // 4. Bantuan / Kontak Kami
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: darkCard,
        title: const Text(
          "Pusat Bantuan",
          style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ada kendala dengan booking Anda? Hubungi kami melalui:",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Icon(Icons.chat_bubble_outline, color: Colors.greenAccent),
                SizedBox(width: 10),
                Text(
                  "WhatsApp: 0812-3456-7890",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: const [
                Icon(Icons.camera_alt_outlined, color: Colors.purpleAccent),
                SizedBox(width: 10),
                Text(
                  "Instagram: @gentlemans_barber",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: goldAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }
}
