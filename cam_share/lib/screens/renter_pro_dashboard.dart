import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cam_share/screens/profile_screen.dart';

// Ensure these imports match your actual file structure
import 'photography_screen.dart';
import 'videography_screen.dart';
import 'accessories_screen.dart';

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
        '/login': (context) => const Scaffold(body: Center(child: Text("Login Placeholder"))),
        '/profile': (context) => const ProfileScreen(),
        '/editProfile': (context) => const Scaffold(body: Center(child: Text("Edit Profile Placeholder"))),
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
  bool _showProMenu = false;

  // Filter Checkbox States
  bool _filterCamera = false;
  bool _filterDrones = false;
  bool _filterAccessories = false;
  bool _filterCanon = false;
  bool _filterNikon = false;
  bool _filterSony = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
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

  void _toggleProMenu() {
    setState(() {
      _showProMenu = !_showProMenu;
    });
  }

  void _navigateToCategory(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
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
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      drawer: Drawer(
        backgroundColor: accentColor, 
        width: 250, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80), 
            GestureDetector(
              onTap: _goToProfile,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white, 
                  child: Icon(Icons.person_outline, size: 35, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              userName.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: _goToProfile,
              child: const Text("add cvr", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w400)),
            ),
            const Spacer(), 
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                onPressed: _logout,
                tooltip: 'Logout',
              ),
            )
          ],
        ),
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(
              children: [
                SizedBox(
                  height: 70,
                  child: Row(
                    children: [
                      Expanded(child: _buildHeaderButton("BEGINNER", accentColor, () {})),
                      const SizedBox(width: 16),
                      Expanded(child: _buildHeaderButton("PRO", accentColor, _toggleProMenu)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // === UPDATED COLUMNS: NOW USING ELEVATED BUTTONS ===
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildVerticalButton(
                        "photography", 
                        cardColor,
                        () => _navigateToCategory(const PhotographyScreen()),
                      ),
                      const SizedBox(width: 12),
                      _buildVerticalButton(
                        "Videography", 
                        cardColor,
                        () => _navigateToCategory(const VideographyScreen()),
                      ),
                      const SizedBox(width: 12),
                      _buildVerticalButton(
                        "Accessories", 
                        cardColor,
                        () => _navigateToCategory(const AccessoriesScreen()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),

          if (_showProMenu)
            Positioned(
              top: 85,
              left: 32,
              right: 16,
              bottom: 100,
              child: _buildProDropdown(accentColor),
            ),
        ],
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: accentColor,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.home, color: Colors.white, size: 36),
        ),
      ),
    );
  }

  Widget _buildProDropdown(Color accentColor) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Device type:", style: TextStyle(color: Colors.white, fontSize: 14)),
              _buildCheckboxRow("Camera", _filterCamera, (v) => setState(() => _filterCamera = v!)),
              _buildCheckboxRow("Drones", _filterDrones, (v) => setState(() => _filterDrones = v!)),
              _buildCheckboxRow("Accessories", _filterAccessories, (v) => setState(() => _filterAccessories = v!)),
              
              const SizedBox(height: 16),
              
              const Text("Device Brands:", style: TextStyle(color: Colors.white, fontSize: 14)),
              _buildCheckboxRow("CANON", _filterCanon, (v) => setState(() => _filterCanon = v!)),
              _buildCheckboxRow("NIKON", _filterNikon, (v) => setState(() => _filterNikon = v!)),
              _buildCheckboxRow("SONY", _filterSony, (v) => setState(() => _filterSony = v!)),

              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    _toggleProMenu();
                  },
                  child: const Text("Search", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.only(right: 50),
          child: CustomPaint(
            painter: TrianglePainter(color: accentColor),
            size: const Size(20, 10),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxRow(String label, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              fillColor: WidgetStateProperty.all(Colors.white),
              checkColor: Colors.blue,
              side: BorderSide.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        elevation: 2,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  // === NEW: Replaced Container+InkWell with ElevatedButton ===
  Widget _buildVerticalButton(String title, Color color, VoidCallback onTap) {
    return Expanded(
      child: SizedBox(
        height: double.infinity, // Force button to fill vertical space
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.black87, // Text/Icon color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 2, // Standard button elevation
            padding: EdgeInsets.zero, // Allows content to be centered
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

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color;
    var path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}