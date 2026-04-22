import 'package:flutter/material.dart';

// 🔥 IMPORT SEMUA PAGE KAMU
import 'home_page.dart';
import 'booking_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentIndex = 0;

  // 🔥 PAGE ASLI (BUKAN TEXT LAGI)
  final List<Widget> pages = [
    HomePage(),
    BookingPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // 🔥 FIX: BIAR GA RELOAD PAGE
      body: IndexedStack(index: currentIndex, children: pages),

      // 🔥 NAVBAR PREMIUM
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(14),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFF121212),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(Icons.home, "Home", 0),
            navItem(Icons.calendar_month, "Booking", 1),

            // 🔥 CENTER BUTTON
            GestureDetector(
              onTap: () {
                setState(() {
                  currentIndex = 1;
                });
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.6),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Icon(Icons.content_cut, color: Colors.black, size: 26),
              ),
            ),

            navItem(Icons.history, "History", 2),
            navItem(Icons.person, "Profile", 3),
          ],
        ),
      ),
    );
  }

  // 🔥 NAV ITEM
  Widget navItem(IconData icon, String label, int index) {
    bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },

      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.amber.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: Duration(milliseconds: 300),
              scale: isActive ? 1.2 : 1,
              child: Icon(icon, color: isActive ? Colors.amber : Colors.grey),
            ),

            SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.amber : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
