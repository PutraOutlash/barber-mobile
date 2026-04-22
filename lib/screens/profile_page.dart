import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),

      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 🔥 PROFILE HEADER
          Column(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.amber,
                child: Icon(Icons.person, size: 50, color: Colors.black),
              ),

              SizedBox(height: 10),

              Text(
                "Ibenn User",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text("ibenn@email.com", style: TextStyle(color: Colors.grey)),
            ],
          ),

          SizedBox(height: 20),

          // 🔥 INFO CARD
          Container(
            padding: EdgeInsets.all(16),
            decoration: box(),
            child: Column(
              children: [
                profileItem(Icons.phone, "Nomor", "08123456789"),
                divider(),
                profileItem(Icons.location_on, "Alamat", "Indonesia"),
                divider(),
                profileItem(Icons.card_membership, "Member", "Premium"),
              ],
            ),
          ),

          SizedBox(height: 20),

          // 🔥 MENU
          Container(
            padding: EdgeInsets.all(16),
            decoration: box(),
            child: Column(
              children: [
                menuItem(Icons.edit, "Edit Profile"),
                divider(),
                menuItem(Icons.lock, "Ubah Password"),
                divider(),
                menuItem(Icons.settings, "Pengaturan"),
                divider(),
                menuItem(Icons.help, "Bantuan"),
              ],
            ),
          ),

          SizedBox(height: 20),

          // 🔴 LOGOUT
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.all(14),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: Color(0xFF1C1C1C),
                  title: Text("Logout", style: TextStyle(color: Colors.white)),
                  content: Text(
                    "Yakin mau logout?",
                    style: TextStyle(color: Colors.grey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // 🔥 nanti arahkan ke login
                      },
                      child: Text("Logout"),
                    ),
                  ],
                ),
              );
            },
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }

  // 🔥 UI COMPONENT

  Widget profileItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber),
        SizedBox(width: 10),
        Expanded(
          child: Text(title, style: TextStyle(color: Colors.grey)),
        ),
        Text(value, style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget menuItem(IconData icon, String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.amber),
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }

  Widget divider() {
    return Divider(color: Colors.grey[800]);
  }

  BoxDecoration box() {
    return BoxDecoration(
      color: Color(0xFF1C1C1C),
      borderRadius: BorderRadius.circular(16),
    );
  }
}
