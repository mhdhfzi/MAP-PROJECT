import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddEquipmentScreen extends StatefulWidget {
  const AddEquipmentScreen({super.key});

  @override
  State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _addEquipment() {
    // TODO: Save name, description, price, and _imageFile to Firestore/Storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Equipment added!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Equipment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile == null
                    ? Container(
                        height: 150,
                        width: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.add_a_photo, size: 50),
                      )
                    : Image.file(_imageFile!,
                        height: 150, width: 150, fit: BoxFit.cover),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              ElevatedButton(
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
