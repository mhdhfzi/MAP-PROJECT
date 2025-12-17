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

              return Dismissible(
                key: Key(doc.id),
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // Swipe Right -> Edit
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditEquipmentScreen(docId: doc.id, data: data),
                      ),
                    );
                    return false; // Don't dismiss the item
                  } else if (direction == DismissDirection.endToStart) {
                    // Swipe Left -> Delete
                    final confirm = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Confirm Delete"),
                        content: const Text(
                            "Are you sure you want to delete this listing?"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancel")),
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Delete")),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await FirebaseFirestore.instance
                          .collection("listings")
                          .doc(doc.id)
                          .delete();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Listing deleted")),
                      );
                    }
                    return confirm;
                  }
                  return false;
                },
                child: Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    onLongPress: () => _showLongPressMenu(context, doc.id, data),
                    leading: _safeImage(data["imageUrl"]),
                    title: Text(data["name"] ?? "No name"),
                    subtitle:
                        Text("RM ${data["price"]}\n${data["description"]}"),
                    isThreeLine: true,
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
