import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../config/api.dart';
import '../services/booking_service.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // --- STATE VARIABLES ---
  List services = [];
  List barbers = [];
  List addons = [];
  List hairstyles = [];
  List timeSlots = [];

  Map<String, dynamic>? selectedService;
  Map<String, dynamic>? selectedBarber;
  Map<String, dynamic>? selectedHairstyle;
  List<Map<String, dynamic>> selectedAddons = [];

  DateTime selectedDate = DateTime.now(); // Default ke hari ini
  String? selectedTime;
  File? customPhoto;

  bool isLoadingData = true;
  bool isSubmitting = false;

  // Daftar 14 Hari ke depan untuk kalender horizontal
  late List<DateTime> upcomingDates;

  // Format Hari & Bulan Bahasa Indonesia
  final List<String> _namaHari = [
    '',
    'SEN',
    'SEL',
    'RAB',
    'KAM',
    'JUM',
    'SAB',
    'MIN',
  ];
  final List<String> _namaBulan = [
    '',
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MEI',
    'JUN',
    'JUL',
    'AGU',
    'SEP',
    'OKT',
    'NOV',
    'DES',
  ];

  @override
  void initState() {
    super.initState();
    // Generate 14 hari ke depan mulai dari hari ini
    upcomingDates = List.generate(
      14,
      (index) => DateTime.now().add(Duration(days: index)),
    );
    _fetchAllData();
  }

  // --- API FETCHERS ---
  Future<void> _fetchAllData() async {
    try {
      var resServ = await http.get(Uri.parse("${Api.baseUrl}/service/get.php"));
      var resBarb = await http.get(
        Uri.parse("${Api.baseUrl}/booking/barbers.php"),
      );
      var resAdd = await http.get(Uri.parse("${Api.baseUrl}/addon/get.php"));
      var resHair = await http.get(
        Uri.parse("${Api.baseUrl}/hairstyle/get.php"),
      );

      if (mounted) {
        setState(() {
          services = jsonDecode(resServ.body);
          barbers = jsonDecode(resBarb.body);
          addons = jsonDecode(resAdd.body);
          hairstyles = jsonDecode(resHair.body);
          isLoadingData = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> _fetchTimeSlots() async {
    if (selectedBarber == null || selectedService == null) return;
    setState(() => timeSlots = []);

    int totalDuration = int.parse(selectedService!['duration'].toString());
    String dateStr =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    var res = await http.get(
      Uri.parse(
        "${Api.baseUrl}/booking/slots.php?date=$dateStr&barber_id=${selectedBarber!['id']}&duration=$totalDuration",
      ),
    );

    if (mounted) {
      setState(() {
        timeSlots = jsonDecode(res.body);
        selectedTime = null;
      });
    }
  }

  // --- LOGIC HELPERS ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        customPhoto = File(image.path);
        selectedHairstyle = null;
      });
    }
  }

  int _calculateTotal() {
    int total = 0;
    if (selectedService != null)
      total += int.parse(selectedService!['price'].toString());
    for (var addon in selectedAddons) {
      total += int.parse(addon['price'].toString());
    }
    return total;
  }

  Future<void> _submitBooking() async {
    if (selectedService == null ||
        selectedBarber == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih Layanan, Barber, dan Jam!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);
    String dateStr =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    int totalDuration = int.parse(selectedService!['duration'].toString());
    DateTime startTime = DateTime.parse("2026-01-01 $selectedTime");
    DateTime endTime = startTime.add(Duration(minutes: totalDuration));
    String endStr =
        "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00";

    var result = await BookingService.createBooking(
      userId: "1",
      serviceId: selectedService!['id'].toString(),
      barberId: selectedBarber!['id'].toString(),
      hairstyleId: selectedHairstyle?['id']?.toString(),
      imageFile: customPhoto,
      date: dateStr,
      startTime: selectedTime!,
      endTime: endStr,
      totalPrice: _calculateTotal().toString(),
    );

    setState(() => isSubmitting = false);

    if (result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking Berhasil!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal: ${result['message']}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- UI BUILDERS ---
  @override
  Widget build(BuildContext context) {
    if (isLoadingData) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.amber),
        title: const Text(
          "BUAT JANJI TEMU",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. LAYANAN UTAMA
            _buildSectionTitle("PILIH LAYANAN UTAMA"),
            const SizedBox(height: 15),
            ...services.map((s) => _buildServiceCard(s)).toList(),
            const SizedBox(height: 30),

            // 2. TAMBAHAN
            if (selectedService != null) ...[
              _buildSectionTitle("TAMBAHAN (OPSIONAL)"),
              const SizedBox(height: 15),
              ...addons.map((a) => _buildAddonCard(a)).toList(),
              const SizedBox(height: 30),
            ],

            // 3. BARBER
            _buildSectionTitle("PILIH BARBER"),
            const SizedBox(height: 15),
            Row(
              children: barbers
                  .map(
                    (b) => Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedBarber = b;
                            _fetchTimeSlots();
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: selectedBarber == b
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFF1A1A1A),
                            border: Border.all(
                              color: selectedBarber == b
                                  ? Colors.amber
                                  : Colors.white10,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.face,
                                color: selectedBarber == b
                                    ? Colors.amber
                                    : Colors.grey,
                                size: 30,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                b['name'],
                                style: TextStyle(
                                  color: selectedBarber == b
                                      ? Colors.white
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 30),

            // 4. JADWAL & JAM (KALENDER GESER)
            _buildSectionTitle("JADWAL & JAM"),
            const SizedBox(height: 15),
            // Kalender Horizontal
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: upcomingDates.length,
                itemBuilder: (context, index) {
                  DateTime date = upcomingDates[index];
                  bool isSelected =
                      date.year == selectedDate.year &&
                      date.month == selectedDate.month &&
                      date.day == selectedDate.day;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = date;
                        _fetchTimeSlots();
                      });
                    },
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        border: Border.all(
                          color: isSelected ? Colors.amber : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _namaHari[date.weekday],
                            style: TextStyle(
                              color: isSelected ? Colors.amber : Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${date.day}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _namaBulan[date.month],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Grid Jam
            if (selectedBarber == null || selectedService == null)
              const Text(
                "Pilih Layanan dan Barber untuk melihat jam tersedia.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              )
            else if (timeSlots.isEmpty)
              const Text(
                "Mencari jadwal...",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              )
            else
              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: timeSlots.map((slot) {
                  bool isAvailable = slot['available'];
                  bool isSelected = selectedTime == slot['start'];
                  return InkWell(
                    onTap: isAvailable
                        ? () => setState(() => selectedTime = slot['start'])
                        : null,
                    child: Container(
                      width:
                          (MediaQuery.of(context).size.width - 75) /
                          3, // Bagi 3 kolom
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.amber.withOpacity(0.1)
                            : const Color(0xFF1A1A1A),
                        border: Border.all(
                          color: isSelected ? Colors.amber : Colors.white10,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        slot['start'],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.amber
                              : (isAvailable ? Colors.grey : Colors.white24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 35),

            // 5. JENIS POTONGAN / CUSTOM
            _buildSectionTitle("JENIS POTONGAN"),
            const SizedBox(height: 15),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                    hairstyles.length + 1, // +1 untuk tombol upload custom
                itemBuilder: (context, index) {
                  // Tombol Custom Photo ditaruh di urutan pertama
                  if (index == 0) {
                    return _buildCustomPhotoCard();
                  }

                  var style = hairstyles[index - 1];
                  bool isSelected =
                      selectedHairstyle == style && customPhoto == null;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedHairstyle = style;
                        customPhoto =
                            null; // Batalkan foto custom jika milih katalog
                      });
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.amber : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            style['image'] != null
                                ? Image.network(
                                    style['image'],
                                    fit: BoxFit.cover,
                                  )
                                : Container(color: const Color(0xFF2A2A2A)),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.center,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              left: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isSelected)
                                    const Text(
                                      "SELECTED",
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  Text(
                                    style['name'].toString().toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
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
                },
              ),
            ),
            const SizedBox(height: 50), // Spasi bawah
          ],
        ),
      ),

      // BOTTOM NAVBAR: TOTAL & SUBMIT
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TOTAL HARGA",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "IDR ${_calculateTotal()}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: isSubmitting ? null : _submitBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.black),
                    )
                  : const Text(
                      "KONFIRMASI",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPONENT BUILDERS ---

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: Colors.amber),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    bool isSelected = selectedService == service;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedService = service;
          _fetchTimeSlots();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border(
            left: BorderSide(
              color: isSelected ? Colors.amber : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PREMIUM",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 8,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  service['name'].toString().toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "IDR ${service['price']}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.content_cut,
              color: isSelected ? Colors.amber : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddonCard(Map<String, dynamic> addon) {
    bool isSelected = selectedAddons.contains(addon);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected)
            selectedAddons.remove(addon);
          else
            selectedAddons.add(addon);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(
            color: isSelected ? Colors.white30 : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "CLASSIC",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 8,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  addon['name'].toString().toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "IDR ${addon['price']}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              color: isSelected ? Colors.amber : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPhotoCard() {
    bool isSelected = customPhoto != null;
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.white10,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              customPhoto != null
                  ? Image.file(customPhoto!, fit: BoxFit.cover)
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, color: Colors.grey, size: 40),
                        SizedBox(height: 10),
                        Text(
                          "UPLOAD\nFOTOMU",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
              if (isSelected)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                    ),
                  ),
                ),
              if (isSelected)
                const Positioned(
                  bottom: 15,
                  left: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SELECTED",
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        "CUSTOM FOTO",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
