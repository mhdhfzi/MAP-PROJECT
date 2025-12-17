import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_equipment_screen.dart';
import 'listing_page.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  String userName = '';
  String userEmail = '';
  List<String> ownerEquipmentIds = [];

  @override
  void initState() {
    super.initState();
    _loadOwnerInfo();
    _loadOwnerEquipment();
  }

  Future<void> _loadOwnerInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          userName = doc.data()?['name'] ?? 'Owner';
          userEmail = doc.data()?['email'] ?? user.email ?? '';
        });
      }
    }
  }

  Future<void> _loadOwnerEquipment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('listings')
          .where('ownerId', isEqualTo: user.uid)
          .get();

      if (mounted) {
        setState(() {
          ownerEquipmentIds = snapshot.docs.map((doc) => doc.id).toList();
        });
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _goToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  void _goToSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Settings clicked")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Colors.deepPurple;
    final Color cardColor = const Color(0xFFF3F3F3);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
        backgroundColor: accentColor,
      ),

      /// ---------- SIDEBAR DRAWER ----------
      drawer: Drawer(
        child: Container(
          color: accentColor,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: _goToProfile,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.person, size: 40, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(userEmail,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 30),
                _buildDrawerItem(Icons.person, "Profile", _goToProfile),
                _buildDrawerItem(Icons.add, "Add Equipment", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddEquipmentScreen()),
                  ).then((added) {
                    if (added == true) {
                      _loadOwnerEquipment(); // Refresh equipment IDs
                    }
                  });
                }),
                _buildDrawerItem(Icons.list, "View Listings", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ListingPage()),
                  );
                }),
                _buildDrawerItem(Icons.settings, "Settings", _goToSettings),
                const Spacer(),
                _buildDrawerItem(Icons.logout, "Logout", _logout),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------- OWNER PROFILE ----------
            Text(
              "Welcome, $userName",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(userEmail, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),

            /// ---------- TWO MAIN BUTTONS ----------
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final added = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddEquipmentScreen(),
                        ),
                      );

                      if (added == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Equipment added successfully!"),
                          ),
                        );
                        _loadOwnerEquipment(); // Refresh equipment IDs
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Equipment"),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ListingPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list),
                    label: const Text("View Listings"),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// ---------- BOOKING REQUESTS ----------
            const Text(
              "Booking Requests",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("booking_requests")
                  .orderBy("date", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No booking requests yet."));
                }

                // Filter booking requests for equipment owned by current owner
                final allRequests = snapshot.data!.docs;
                final ownerRequests = allRequests.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final equipmentId = data['equipmentId'] ?? '';
                  return ownerEquipmentIds.contains(equipmentId);
                }).toList();

                if (ownerRequests.isEmpty) {
                  return const Center(child: Text("No booking requests yet."));
                }

                return Column(
                  children: ownerRequests.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] ?? "Pending";

                    return Dismissible(
                      key: Key(doc.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        await FirebaseFirestore.instance
                            .collection("booking_requests")
                            .doc(doc.id)
                            .delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Booking request deleted")),
                        );
                      },
                      child: Card(
                        color: cardColor,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          title: Text(
                            data["equipmentName"] ?? "Unnamed Equipment",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Renter: ${data['renterName'] ?? 'Unknown'}\nDate: ${data['date'] != null ? (data['date'] as Timestamp).toDate().toLocal().toString().split(' ')[0] : 'N/A'}",
                          ),
                          trailing: status == "Pending"
                              ? ElevatedButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection("booking_requests")
                                        .doc(doc.id)
                                        .update({"status": "Accepted"});
                                  },
                                  child: const Text("Accept"),
                                )
                              : Text(
                                  "Accepted",
                                  style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold),
                                ),
                          onLongPress: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              builder: (_) {
                                return SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.delete, color: Colors.red),
                                        title: const Text("Cancel Request"),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await FirebaseFirestore.instance
                                              .collection("booking_requests")
                                              .doc(doc.id)
                                              .delete();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text("Booking request cancelled")),
                                          );
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.close),
                                        title: const Text("Close"),
                                        onTap: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}
