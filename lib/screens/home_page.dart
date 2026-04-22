import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int total = 0;
  int revenue = 0;
  List pie = [];

  DateTime? startDate;
  DateTime? endDate;

  bool loading = true;

  int touchedIndex = -1; // 🔥 index slice yg di klik

  @override
  void initState() {
    super.initState();
    loadData();
  }

  int toInt(dynamic v) => int.tryParse(v.toString()) ?? 0;

  double getTotalPie() {
    double t = 0;
    for (var p in pie) {
      t += toInt(p['total']);
    }
    return t;
  }

  Future<void> loadData() async {
    setState(() => loading = true);

    String url = "http://127.0.0.1/barber_api/dashboard_filter.php";

    if (startDate != null && endDate != null) {
      String s = DateFormat('yyyy-MM-dd').format(startDate!);
      String e = DateFormat('yyyy-MM-dd').format(endDate!);
      url += "?start=$s&end=$e";
    }

    try {
      var res = await http.get(Uri.parse(url));
      var data = jsonDecode(res.body);

      setState(() {
        total = toInt(data['total']);
        revenue = toInt(data['revenue']);
        pie = data['pie'] ?? [];
        loading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() => loading = false);
    }
  }

  Future pickDate() async {
    DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (range != null) {
      startDate = range.start;
      endDate = range.end;
      loadData();
    }
  }

  Color getColor(int i) {
    List<Color> colors = [
      Colors.amber,
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.orange,
    ];
    return colors[i % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.date_range, color: Colors.amber),
            onPressed: pickDate,
          ),
        ],
      ),

      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text(
                  "Statistik",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),

                SizedBox(height: 20),

                Row(
                  children: [
                    stat("Total", total),
                    SizedBox(width: 10),
                    stat("Revenue", revenue),
                  ],
                ),

                SizedBox(height: 20),

                // 🔥 PIE INTERAKTIF
                Container(
                  height: 300,
                  padding: EdgeInsets.all(16),
                  decoration: box(),
                  child: pie.isEmpty
                      ? Center(
                          child: Text(
                            "No Data",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (event, response) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          response == null ||
                                          response.touchedSection == null) {
                                        touchedIndex = -1;
                                        return;
                                      }
                                      touchedIndex = response
                                          .touchedSection!
                                          .touchedSectionIndex;
                                    });
                                  },
                                ),

                                sectionsSpace: 2,
                                centerSpaceRadius: 60,

                                sections: List.generate(pie.length, (i) {
                                  final isTouched = i == touchedIndex;
                                  final value = toInt(
                                    pie[i]['total'],
                                  ).toDouble();
                                  final percent = getTotalPie() == 0
                                      ? 0
                                      : (value / getTotalPie() * 100);

                                  return PieChartSectionData(
                                    color: getColor(i),
                                    value: value,
                                    title: "${percent.toStringAsFixed(1)}%",
                                    radius: isTouched ? 85 : 70,
                                    titleStyle: TextStyle(
                                      fontSize: isTouched ? 14 : 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }),
                              ),
                              swapAnimationDuration: Duration(
                                milliseconds: 800,
                              ),
                              swapAnimationCurve: Curves.easeInOut,
                            ),

                            // 🔥 CENTER INFO
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  touchedIndex == -1
                                      ? "Total"
                                      : pie[touchedIndex]['service'],
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  touchedIndex == -1
                                      ? total.toString()
                                      : pie[touchedIndex]['total'].toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),

                SizedBox(height: 20),

                // 🔥 LEGEND
                Wrap(
                  spacing: 10,
                  children: List.generate(pie.length, (i) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 10, height: 10, color: getColor(i)),
                        SizedBox(width: 5),
                        Text(
                          pie[i]['service'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
    );
  }

  Widget stat(String title, int value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: box(),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 10),
            Text(
              title == "Revenue"
                  ? "Rp ${NumberFormat('#,###').format(value)}"
                  : value.toString(),
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration box() {
    return BoxDecoration(
      color: Color(0xFF1C1C1C),
      borderRadius: BorderRadius.circular(16),
    );
  }
}
