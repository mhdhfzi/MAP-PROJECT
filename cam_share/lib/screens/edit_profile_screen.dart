import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _matricController = TextEditingController();
  final _phoneController = TextEditingController();

  final UserService _userService = UserService();
  bool _isLoading = false;

  String dummyProfileUrl = 'https://via.placeholder.com/150'; // Dummy profile picture

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _matricController.text = 'A1234567';
    _phoneController.text = '+60 123456789';
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final user = await _userService.getUser(currentUser.uid);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data not found!')),
      );
      Navigator.pop(context);
      return;
    }

    if (!mounted) return;
    setState(() {
      _nameController.text = user.name;
      _emailController.text = user.email;
    });
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final updatedUser = UserModel(
        uid: uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        userType: 'owner', // keep role consistent
      );

      await _userService.updateUser(updatedUser);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _matricController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), backgroundColor: Colors.deepPurple),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(dummyProfileUrl),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _matricController,
              decoration: const InputDecoration(labelText: 'Matric ID'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text('Save Changes'),
                  ),
          ],
        ),
      ),
    );
  }
}
