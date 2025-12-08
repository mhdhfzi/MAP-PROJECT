import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccessoriesScreen extends StatelessWidget {
  const AccessoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color accentColor = const Color(0xFF4A00E0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Accessories", style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildHeaderButton("BEGINNER", accentColor, () => Navigator.pop(context))),
                const SizedBox(width: 16),
                Expanded(child: _buildHeaderButton("PRO", accentColor, () => Navigator.pop(context))),
              ],
            ),
            const SizedBox(height: 20),

            // === REAL-TIME FIRESTORE LIST ===
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8), 
                  borderRadius: BorderRadius.circular(8),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .where('category', isEqualTo: 'accessories')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text("Error loading accessories"));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No accessories listed."));
                    }

                    final docs = snapshot.data!.docs;
                    
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                      itemBuilder: (ctx, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        return _buildListItem(data);
                      },
                    );
                  },
                ),
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
          onPressed: () => Navigator.pop(context),
          backgroundColor: accentColor,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.home, color: Colors.white, size: 36),
        ),
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[600],
            borderRadius: BorderRadius.circular(4),
            image: data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(data['imageUrl']),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: (data['imageUrl'] == null || data['imageUrl'].toString().isEmpty) 
              ? const Icon(Icons.cable, color: Colors.white54) 
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['name'] ?? "Accessory Item",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                "RM ${data['price'] ?? '0'}",
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildHeaderButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 2,
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
