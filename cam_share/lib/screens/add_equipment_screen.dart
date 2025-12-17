import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEquipmentScreen extends StatefulWidget {
  const AddEquipmentScreen({super.key});

  @override
  State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  String _selectedCategory = "Photography"; // Default category
  final List<String> _categories = ["Photography", "Videography", "Accessories"];

  bool _isLoading = false;

  Future<void> _addEquipment() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _imageUrlController.text.isEmpty ||
        _selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection("listings").add({
        "name": _nameController.text.trim(),
        "description": _descriptionController.text.trim(),
        "price": double.parse(_priceController.text.trim()),
        "imageUrl": _imageUrlController.text.trim(),
        "category": _selectedCategory, // Add category field
        "createdAt": Timestamp.now(),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Equipment added!")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Equipment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Equipment Name"),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _imageUrlController,
                decoration:
                    const InputDecoration(labelText: "Image URL (Paste here)"),
              ),
              const SizedBox(height: 16),
              // Dropdown for category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: "Category"),
                items: _categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _addEquipment,
                      child: const Text("Add Equipment"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
