import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';
import 'photography_screen.dart';
import 'videography_screen.dart';
import 'accessories_screen.dart';
import 'cart_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Photography App',
      routes: {
        '/login': (context) =>
            const Scaffold(body: Center(child: Text("Login Placeholder"))),
        '/profile': (context) => const ProfileScreen(),
        '/editProfile': (context) =>
            const Scaffold(body: Center(child: Text("Edit Profile Placeholder"))),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const RenterProDashboard(),
    );
  }
}

class RenterProDashboard extends StatefulWidget {
  const RenterProDashboard({super.key});

  @override
  State<RenterProDashboard> createState() => _RenterProDashboardState();
}

class _RenterProDashboardState extends State<RenterProDashboard> {
  String userName = 'Loading...';
  String userEmail = '';

  // Shared cart list
  final List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          userName = doc.data()?['name'] ?? 'User';
          userEmail = doc.data()?['email'] ?? user.email ?? '';
        });
      }
    } else {
      setState(() {
        userName = "USERNAME";
        userEmail = "";
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _goToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  void _navigateToPhotography() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotographyScreen(cartItems: cartItems),
      ),
    );
  }

  void _navigateToVideography() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideographyScreen(cartItems: cartItems),
      ),
    );
  }

  void _navigateToAccessories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccessoriesScreen(cartItems: cartItems),
      ),
    );
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(cartItems: cartItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = const Color(0xFF4A00E0);
    final Color cardColor = const Color(0xFFF0F4F8);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Colors.black, size: 28),
                onPressed: _navigateToCart,
              ),
              if (cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cartItems.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: accentColor,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _goToProfile,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.person, size: 40, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 12),
                Text(userName.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 4),
                Text(userEmail,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 20),
                const Divider(color: Colors.white30),
                const SizedBox(height: 10),
                _buildDrawerItem(Icons.home, "Dashboard", () => Navigator.pop(context)),
                _buildDrawerItem(Icons.person, "Profile", _goToProfile),
                _buildDrawerItem(Icons.settings, "Settings", () {}),
                _buildDrawerItem(Icons.help, "Help", () {}),
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text("Logout",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildVerticalButton(
                    "Photography",
                    cardColor,
                    _navigateToPhotography,
                  ),
                  const SizedBox(width: 12),
                  _buildVerticalButton(
                    "Videography",
                    cardColor,
                    _navigateToVideography,
                  ),
                  const SizedBox(width: 12),
                  _buildVerticalButton(
                    "Accessories",
                    cardColor,
                    _navigateToAccessories,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          onPressed: _navigateToCart,
          backgroundColor: accentColor,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.shopping_cart, color: Colors.white, size: 36),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  Widget _buildVerticalButton(String title, Color color, VoidCallback onTap) {
    return Expanded(
      child: SizedBox(
        height: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 2,
            padding: EdgeInsets.zero,
          ),
          onPressed: onTap,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
