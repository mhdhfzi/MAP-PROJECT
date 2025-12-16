import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_equipment_screen.dart';

class ListingPage extends StatelessWidget {
  const ListingPage({super.key});

  /// ✅ SAFE IMAGE WIDGET (CRASH-PROOF)
  Widget _safeImage(String? url) {
    if (url == null ||
        url.isEmpty ||
        (!url.startsWith("http")) ||
        (!url.endsWith(".jpg") &&
            !url.endsWith(".png") &&
            !url.endsWith(".jpeg") &&
            !url.endsWith(".webp"))) {
      return const Icon(
        Icons.image_not_supported,
        size: 50,
        color: Colors.grey,
      );
    }

    return Image.network(
      url,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return const Icon(Icons.broken_image, size: 50, color: Colors.red);
      },
    );
  }

  /// ✅ LONG PRESS MENU
  void _showLongPressMenu(
    BuildContext context,
    String docId,
    Map<String, dynamic> item,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text("Edit Listing"),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditEquipmentScreen(docId: docId, data: item),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete Listing"),
                onTap: () async {
                  Navigator.pop(context);

                  await FirebaseFirestore.instance
                      .collection("listings")
                      .doc(docId)
                      .delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Listing deleted")),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text("Cancel"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Listings"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("listings")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No listings yet"));
          }

          final listings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final doc = listings[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  onLongPress: () => _showLongPressMenu(context, doc.id, data),

                  leading: _safeImage(data["imageUrl"]),
                  title: Text(data["name"] ?? "No name"),
                  subtitle: Text("RM ${data["price"]}\n${data["description"]}"),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
