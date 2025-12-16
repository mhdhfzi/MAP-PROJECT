import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditEquipmentScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const EditEquipmentScreen({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  State<EditEquipmentScreen> createState() => _EditEquipmentScreenState();
}

class _EditEquipmentScreenState extends State<EditEquipmentScreen> {
  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late TextEditingController imageUrlController;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.data["name"] ?? "");
    descController =
        TextEditingController(text: widget.data["description"] ?? "");
    priceController =
        TextEditingController(text: widget.data["price"]?.toString() ?? "0");
    imageUrlController =
        TextEditingController(text: widget.data["imageUrl"] ?? "");
  }

  Future<void> saveChanges() async {
    if (nameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and price are required")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection("listings")
        .doc(widget.docId)
        .update({
      "name": nameController.text.trim(),
      "description": descController.text.trim(),
      "price": double.tryParse(priceController.text.trim()) ?? 0,
      "imageUrl": imageUrlController.text.trim(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Listing updated successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Equipment"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Equipment Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Price (RM)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: imageUrlController,
              decoration: const InputDecoration(labelText: "Image URL"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveChanges,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
