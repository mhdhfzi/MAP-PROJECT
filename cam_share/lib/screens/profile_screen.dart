import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No user data found."));
          }

          final userData = snapshot.data!;

          // Derive status properly
          String status;
          if (userData['role'] == 'owner') {
            status = 'Owner';
          } else if (userData['role'] == 'renter') {
            status = (userData['type'] == 'pro') ? 'Pro' : 'Beginner';
          } else {
            status = 'Unknown';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Picture Placeholder
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Name Card
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Name"),
                    subtitle: Text(userData['name']),
                  ),
                ),
                const SizedBox(height: 10),

                // Email Card
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text("Email"),
                    subtitle: Text(userData['email']),
                  ),
                ),
                const SizedBox(height: 10),

                // Status / UserType Card
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text("Status"),
                    subtitle: Text(status),
                  ),
                ),
                const SizedBox(height: 10),

                // Matric Number Card 
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.confirmation_number),
                    title: Text("Matric Number"),
                    subtitle: Text("A1234567"),
                  ),
                ),
                const SizedBox(height: 10),

                // Phone Number Card (dummy)
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.phone),
                    title: Text("Phone Number"),
                    subtitle: Text("+60123456789"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/editProfile');
        },
        label: const Text('Edit Profile'),
        icon: const Icon(Icons.edit),
        backgroundColor: null, // default button color
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
