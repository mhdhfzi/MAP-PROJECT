import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'listing_page.dart';
import 'add_equipment_screen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  String userName = "John Owner";
  String userEmail = "owner@example.com";

  void _addEquipmentToFirestore(Map<String, dynamic> item) async {
    await FirebaseFirestore.instance.collection("listings").add({
      "name": item["name"],
      "description": item["description"],
      "price": item["price"],
      "imageUrl": item["imageUrl"],
      "createdAt": Timestamp.now(),
    });
  }

  Widget _buildStatusButtons(String docId, String status) {
    if (status == "accepted") {
      return const Text(
        "Accepted",
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      );
    }

    if (status == "rejected") {
      return const Text(
        "Rejected",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () {
            FirebaseFirestore.instance
                .collection("booking_requests")
                .doc(docId)
                .update({"status": "accepted"});
          },
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {
            FirebaseFirestore.instance
                .collection("booking_requests")
                .doc(docId)
                .update({"status": "rejected"});
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            tooltip: "Logout",
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, $userName",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(userEmail),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final newItem = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddEquipmentScreen(),
                        ),
                      );

                      if (newItem != null) {
                        _addEquipmentToFirestore(newItem);
                      }
                    },
                    child: const Text("Add Equipment"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ListingPage()),
                      );
                    },
                    child: const Text("View Listings"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Booking Requests",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("booking_requests")
                  .orderBy("date", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final requests = snapshot.data!.docs;

                if (requests.isEmpty) {
                  return const Text("No booking requests yet");
                }

                return Column(
                  children: requests.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final id = doc.id;

                    return Card(
                      child: ListTile(
                        title: Text(data["equipmentName"]),
                        subtitle: Text(
                          "Renter: ${data['renterName']}\n"
                          "Date: ${data['date'].toDate()}",
                        ),
                        trailing: _buildStatusButtons(id, data["status"]),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
