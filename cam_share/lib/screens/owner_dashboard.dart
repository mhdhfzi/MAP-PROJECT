import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_equipment_screen.dart';
import 'listing_page.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  String userName = 'Loading...';
  String userEmail = '';

  // Dummy booking requests (replace with Firestore later if needed)
  List<Map<String, dynamic>> bookingRequests = [
    {
      "equipment": "Canon EOS R5",
      "renter": "Ali",
      "date": "18 Nov 2025",
      "status": "Pending"
    },
    {
      "equipment": "Sony A7III",
      "renter": "Siti",
      "date": "20 Nov 2025",
      "status": "Pending"
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadOwnerInfo();
  }

  Future<void> _loadOwnerInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          userName = doc.data()?['name'] ?? 'Owner';
          userEmail = doc.data()?['email'] ?? user.email ?? '';
        });
      }
    }
  }

  void _acceptBooking(int index) {
    setState(() {
      bookingRequests[index]["status"] = "Accepted";
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _goToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: "Profile",
            onPressed: _goToProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------- OWNER PROFILE ----------
            Text(
              "Welcome, $userName",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(userEmail),
            const SizedBox(height: 20),

            /// ---------- TWO MAIN BUTTONS ----------
            Row(
              children: [
                /// ADD NEW EQUIPMENT
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final added = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddEquipmentScreen(),
                        ),
                      );

                      if (added == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Equipment added successfully!"),
                          ),
                        );
                      }
                    },
                    child: const Text("Add Equipment"),
                  ),
                ),
                const SizedBox(width: 16),

                /// VIEW LISTINGS (Powered by Firestore)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ListingPage(),
                        ),
                      );
                    },
                    child: const Text("View Listings"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// ---------- BOOKING REQUESTS ----------
            const Text(
              "Booking Requests",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...bookingRequests.asMap().entries.map((entry) {
              int index = entry.key;
              var request = entry.value;

              return Card(
                child: ListTile(
                  title: Text(request["equipment"]),
                  subtitle: Text(
                    "Renter: ${request['renter']}\nDate: ${request['date']}",
                  ),
                  trailing: request["status"] == "Pending"
                      ? ElevatedButton(
                          onPressed: () => _acceptBooking(index),
                          child: const Text("Accept"),
                        )
                      : const Text(
                          "Accepted",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
