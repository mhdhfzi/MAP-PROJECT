import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingRequestPage extends StatelessWidget {
  const BookingRequestPage({super.key});

  void _bookEquipment(
    BuildContext context,
    Map<String, dynamic> item,
    String docId,
  ) async {
    const renterName = "Test Renter"; // Replace with Firebase Auth user later
    const renterId = "dummy_user_123";

    await FirebaseFirestore.instance.collection("booking_requests").add({
      "equipmentId": docId,
      "equipmentName": item["name"],
      "equipmentImage": item["imageUrl"] ?? "",
      "renterName": renterName,
      "renterId": renterId,
      "message": "Hi, I want to rent this",
      "date": Timestamp.now(),
      "status": "pending",
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Booking request sent!")));
  }

  Widget _safeImage(String? url) {
    if (url == null || url.isEmpty || !url.contains(".")) {
      return const Icon(Icons.broken_image, size: 50, color: Colors.red);
    }

    return Image.network(
      url,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, size: 50, color: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Equipment"),
        backgroundColor: Colors.deepPurple,
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("listings")
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

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
                  leading: _safeImage(item["imageUrl"]),
                  title: Text(item["name"] ?? "Unnamed Item"),
                  subtitle: Text(
                    "RM ${item['price'] ?? '--'}\n${item['description'] ?? 'No description'}",
                  ),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: () => _bookEquipment(context, item, docId),
                    child: const Text("Book"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
