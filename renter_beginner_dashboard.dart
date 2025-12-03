import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RenterDashboard extends StatefulWidget {
  const RenterDashboard({super.key});

  @override
  State<RenterDashboard> createState() => _RenterDashboardState();
}

class _RenterDashboardState extends State<RenterDashboard> {
  String userName = '';
  String userEmail = '';
  bool isLoading = true;
  String searchQuery = '';
  String selectedCategory = 'All';
  final ScrollController _scrollController = ScrollController();

  final List<String> categories = ['All', 'Photography', 'Videography', 'Accessories'];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        userName = doc['name'] ?? 'User';
        userEmail = doc['email'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        userName = 'User';
        userEmail = '';
        isLoading = false;
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // Profile Section with Logout menu
  Widget _buildProfileSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // user info left, menu right
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 40)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(userEmail, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') _logout();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }

  // Category Icons
  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'photography':
        return Icons.camera_alt;
      case 'videography':
        return Icons.videocam;
      case 'accessories':
        return Icons.headset;
      default:
        return Icons.devices;
    }
  }

  // Equipment Section
  Widget _buildEquipmentSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Browse Equipment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Search bar
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search equipment...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => searchQuery = value),
          ),

          const SizedBox(height: 8),

          // Category Filters
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                bool isSelected = category == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => setState(() => selectedCategory = category),
                    selectedColor: Colors.blue.shade300,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Equipment Grid
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('equipment').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              List<DocumentSnapshot> items = snapshot.data!.docs;

              // Search + Filter
              items = items.where((doc) {
                final name = (doc['name'] ?? '').toString().toLowerCase();
                final category = (doc['category'] ?? '').toString();
                final matchesSearch = name.contains(searchQuery.toLowerCase());
                final matchesCategory = selectedCategory == 'All' || category == selectedCategory;
                return matchesSearch && matchesCategory;
              }).toList();

              if (items.isEmpty) return const Text('No equipment found.');

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 3 / 2,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          getCategoryIcon(item['category'] ?? ''),
                          size: 40,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        Text(item['name'] ?? '', textAlign: TextAlign.center),
                        Text(item['category'] ?? '', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Requests Section
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRequestsSection() {
    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Rental Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            const TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Pending'),
                Tab(text: 'Approved'),
                Tab(text: 'Rejected'),
              ],
            ),

            SizedBox(
              height: 300,
              child: TabBarView(
                children: ['pending', 'approved', 'rejected'].map((status) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('rentalRequests')
                        .where('status', isEqualTo: status)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final requests = snapshot.data!.docs;
                      if (requests.isEmpty) return const Center(child: Text('No requests.'));
                      return ListView.builder(
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final req = requests[index];
                          return Card(
                            child: ListTile(
                              title: Text(req['equipmentName'] ?? 'Equipment'),
                              subtitle: Text('Date: ${req['date']?.toDate().toString().split(' ')[0] ?? ''}'),
                              trailing: Text(
                                req['status'].toString().toUpperCase(),
                                style: TextStyle(color: getStatusColor(req['status'])),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beginner Renter Dashboard')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileSection(),
                  _buildEquipmentSection(),
                  _buildRequestsSection(),
                ],
              ),
            ),
    );
  }
}
