import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // 🔥 Wajib di-import untuk fitur Timer Jam
import 'booking_page.dart';
import 'product_page.dart';
import '../services/hairstyle_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variabel penampung data dinamis
  String userName = "MEMUAT...";
  String currentTime = "SISTEM AKTIF / --:--";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _updateTime(); // Panggil jam saat pertama kali buka

    // 🔥 Mesin Jam: Perbarui waktu setiap 1 menit
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Matikan jam saat pindah halaman agar hemat RAM
    super.dispose();
  }

  // --- FUNGSI AMBIL NAMA DARI MEMORI HP ---
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Mengambil nama dan langsung mengubahnya menjadi HURUF KAPITAL semua
      String rawName = prefs.getString("user_name") ?? "GUEST";
      userName = rawName.toUpperCase();
    });
  }

  // --- FUNGSI JAM REAL-TIME ---
  void _updateTime() {
    final now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    String ampm = hour >= 12 ? 'PM' : 'AM';

    hour = hour % 12;
    hour = hour == 0 ? 12 : hour; // Format 12 jam (ubah 00 jadi 12)

    String hrStr = hour.toString().padLeft(2, '0');
    String minStr = minute.toString().padLeft(2, '0');

    if (mounted) {
      setState(() {
        currentTime = "SISTEM AKTIF / $hrStr:$minStr $ampm";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER DINAMIS ---
              Text(
                currentTime, // 🔥 Jam Real-time
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "HALO, $userName", // 🔥 Nama User Asli
                style: const TextStyle(
                  color: Color(0xFFE5C07B),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 25),

              // --- BANNER PROMO ---
              Container(
                width: double.infinity,
                height: 140,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: const Color(0xFFE5C07B),
                      child: const Text(
                        "PROMO TERBATAS",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "DISKON 30% VIP\nTREATMENT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- MENU BUTTONS ---
              Row(
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      title: "KATALOG GAYA",
                      subtitle: "PILIH KARAKTERMU",
                      icon: Icons.style,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BookingPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildMenuCard(
                      title: "TOKO PRODUK",
                      subtitle: "AMUNISI PERAWATAN",
                      icon: Icons.shopping_bag,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProductPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),

              // --- GAYA RAMBUT POPULER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    "GAYA RAMBUT POPULER",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "LIHAT SEMUA",
                    style: TextStyle(
                      color: Color(0xFFE5C07B),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // FETCH DATA GAYA RAMBUT DARI DATABASE
              FutureBuilder<List<dynamic>>(
                future: HairstyleService.getHairstyles(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 220,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return const SizedBox(
                      height: 220,
                      child: Center(
                        child: Text(
                          "Gagal memuat data",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox(
                      height: 220,
                      child: Center(
                        child: Text(
                          "Belum ada gaya rambut",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  var hairstyles = snapshot.data!;
                  return SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: hairstyles.length,
                      itemBuilder: (context, index) {
                        return _buildHairstyleCard(hairstyles[index]);
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 35),

              // --- LAYANAN REKOMENDASI ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "LAYANAN\nREKOMENDASI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    "BERDASARKAN\nRIWAYAT",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // KOTAK ISI LAYANAN REKOMENDASI
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.content_cut,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Premium Haircut",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Sesuai dengan riwayat bulan lalu",
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BookingPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        minimumSize: const Size(60, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text(
                        "BOOKING",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 8,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHairstyleCard(Map<String, dynamic> data) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                image: data['image'] != null
                    ? DecorationImage(
                        image: NetworkImage(data['image']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: data['image'] == null
                  ? const Center(
                      child: Icon(Icons.image, color: Colors.grey, size: 40),
                    )
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? "Style",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Premium Cut",
                        style: TextStyle(color: Colors.grey, fontSize: 8),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.bookmark_border, color: Colors.grey, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
