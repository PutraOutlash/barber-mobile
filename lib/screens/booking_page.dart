import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String selectedService = "Haircut";
  String selectedDate = "";
  String selectedTime = "";

  List services = [
    {"name": "Haircut", "price": "150K"},
    {"name": "Shave", "price": "85K"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: Text("Booking", style: TextStyle(color: Colors.amber)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),

      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 🔥 SERVICE
          Text("Pilih Layanan", style: titleStyle()),

          SizedBox(height: 10),

          ...services.map((s) => serviceCard(s)).toList(),

          SizedBox(height: 20),

          // 📅 DATE
          Text("Tanggal", style: titleStyle()),

          SizedBox(height: 10),

          ElevatedButton(
            onPressed: pickDate,
            child: Text(selectedDate == "" ? "Pilih Tanggal" : selectedDate),
          ),

          SizedBox(height: 20),

          // ⏰ TIME
          Text("Jam", style: titleStyle()),

          SizedBox(height: 10),

          ElevatedButton(
            onPressed: pickTime,
            child: Text(selectedTime == "" ? "Pilih Jam" : selectedTime),
          ),

          SizedBox(height: 30),

          // 📦 SUMMARY
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ringkasan", style: titleStyle()),
                SizedBox(height: 10),
                Text(
                  "Service: $selectedService",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "Tanggal: $selectedDate",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "Jam: $selectedTime",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // 🔘 BUTTON
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: EdgeInsets.all(15),
            ),
            onPressed: saveBooking,
            child: Text(
              "BAYAR SEKARANG",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget serviceCard(service) {
    bool selected = selectedService == service['name'];

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedService = service['name'];
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Colors.amber : Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              service['name'],
              style: TextStyle(color: selected ? Colors.black : Colors.white),
            ),
            Text(
              service['price'],
              style: TextStyle(color: selected ? Colors.black : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle titleStyle() {
    return GoogleFonts.poppins(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
  }

  void pickDate() async {
    var date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        selectedDate = date.toString().split(" ")[0];
      });
    }
  }

  void pickTime() async {
    var time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = time.format(context);
      });
    }
  }

  void saveBooking() {
    print("Service: $selectedService");
    print("Date: $selectedDate");
    print("Time: $selectedTime");

    // nanti sambungkan ke API
  }
}
