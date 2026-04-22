import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getHistory();
  }

  // 🔥 GET DATA
  void getHistory() async {
    var res = await http.get(
      Uri.parse("http://localhost/barber_api/get_booking.php"),
    );

    var data = jsonDecode(res.body);

    setState(() {
      bookings = data;
      isLoading = false;
    });
  }

  // ❌ DELETE
  void deleteBooking(id) async {
    await http.post(
      Uri.parse("http://localhost/barber_api/delete_booking.php"),
      body: {"id": id},
    );

    getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: Text("History Booking"),
        backgroundColor: Colors.black,
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : bookings.isEmpty
          ? Center(
              child: Text(
                "Belum ada booking",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => getHistory(),
              child: ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: bookings.length,
                itemBuilder: (context, i) {
                  var b = bookings[i];

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔥 HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              b['name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteBooking(b['id']),
                            ),
                          ],
                        ),

                        SizedBox(height: 6),

                        // 📌 SERVICE
                        Text(
                          "✂ ${b['service']}",
                          style: TextStyle(color: Colors.amber),
                        ),

                        SizedBox(height: 4),

                        // 📅 DATE
                        Text(
                          "📅 ${b['date']}",
                          style: TextStyle(color: Colors.grey),
                        ),

                        // ⏰ TIME
                        Text(
                          "⏰ ${b['time']}",
                          style: TextStyle(color: Colors.grey),
                        ),

                        SizedBox(height: 10),

                        // 🔥 STATUS BADGE
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "SELESAI",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
