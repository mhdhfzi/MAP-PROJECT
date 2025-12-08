import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_equipment_screen.dart';

class ListingPage extends StatelessWidget {
  const ListingPage({super.key});

  bool isValidImageUrl(String url) {
    url = url.toLowerCase();
    return url.endsWith(".jpg") ||
        url.endsWith(".jpeg") ||
        url.endsWith(".png") ||
        url.contains("cdn.pixabay.com") ||
        url.contains("images.unsplash.com");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Listings"),
        backgroundColor: Colors.deepPurple,
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("listings")
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No listings yet"));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var item = doc.data() as Map<String, dynamic>;
              var docId = doc.id;

              String imageUrl = item["imageUrl"] ?? "";
              bool validImage = isValidImageUrl(imageUrl);

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: validImage
                      ? Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.broken_image, size: 50, color: Colors.red),
                        )
                      : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),

                  title: Text(item["name"]),
                  subtitle: Text("RM ${item['price']}\n${item['description']}"),
                  isThreeLine: true,

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // EDIT BUTTON
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditEquipmentScreen(
                                docId: docId,
                                data: item,
                              ),
                            ),
                          );
                        },
                      ),

                      // DELETE BUTTON
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("listings")
                              .doc(docId)
                              .delete();
                        },
                      ),
                    ],
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
