import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RenterDashboard extends StatefulWidget {
  const RenterDashboard({super.key});

  @override
  State<RenterDashboard> createState() => _RenterDashboardState();
}

class _RenterDashboardState extends State<RenterDashboard> {
  String userName = '';
  String userEmail = '';
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser!;
    userId = user.uid;

    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    setState(() {
      userName = doc['name'] ?? '';
      userEmail = doc['email'] ?? '';
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // ------------------------------
  // BOOKING FUNCTION
  // ------------------------------
  Future<void> _sendBookingRequest(Map<String, dynamic> item, String listingId) async {
    await FirebaseFirestore.instance.collection("booking_requests").add({
      "equipmentId": listingId,
      "equipmentName": item["name"],
      "renterName": userName,
      "renterId": userId,
      "date": Timestamp.now(),
      "status": "pending",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Booking request sent!")),
    );
  }

  // ------------------------------
  // BOOKING REQUEST PAGE (INSIDE SAME FILE)
  // ------------------------------
  Widget bookingPage() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("listings")
          .orderBy("createdAt", descending: true)
          .snapshots(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final listings = snapshot.data!.docs;
        if (listings.isEmpty) {
          return const Center(child: Text("No equipment available"));
        }

        return ListView.builder(
          itemCount: listings.length,
          itemBuilder: (context, index) {
            var item = listings[index].data() as Map<String, dynamic>;
            var docId = listings[index].id;

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: Image.network(
                  item["imageUrl"] ?? "",
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 50, color: Colors.red),
                ),

                title: Text(item["name"]),
                subtitle: Text("RM ${item['price']}\n${item['description']}"),
                isThreeLine: true,

                trailing: ElevatedButton(
                  onPressed: () => _sendBookingRequest(item, docId),
                  child: const Text("Book"),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ------------------------------
  // MAIN DASHBOARD UI
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,  // Dashboard + Booking Page
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Renter Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: "Dashboard"),
              Tab(icon: Icon(Icons.shopping_cart), text: "Book Gear"),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            // ------------ TAB 1: Dashboard -----------
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome, $userName', style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 10),
                  Text('Email: $userEmail', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  const Text(
                    'Select "Book Gear" tab above to browse equipment.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ------------ TAB 2: Booking Page -----------
            bookingPage(),
          ],
        ),
      ),
    );
  }
}
