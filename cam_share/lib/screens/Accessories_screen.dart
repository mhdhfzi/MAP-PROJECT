import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_screen.dart';

class AccessoriesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const AccessoriesScreen({super.key, required this.cartItems});

  @override
  State<AccessoriesScreen> createState() => _AccessoriesScreenState();
}

class _AccessoriesScreenState extends State<AccessoriesScreen> {
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
        title: const Text("Accessories",
            style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Colors.black),
                onPressed: _goToCart,
              ),
              if (widget.cartItems.isNotEmpty)
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
                      widget.cartItems.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('listings')
              .where('category', isEqualTo: 'Accessories')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No accessories available"));
            }

            final items = snapshot.data!.docs;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (ctx, i) => const SizedBox(height: 16),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final item = items[i];
                final data = item.data() as Map<String, dynamic>;

                return _buildListItem(
                  data['name'] ?? "Unnamed Item",
                  data['price'] ?? 0,
                  data['imageUrl'] ?? '',
                  data['ownerId'] ?? '',
                  item.id,
                );
              },
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: widget.cartItems.isEmpty ? null : _goToCart,
          child: const Text(
            "Checkout",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }

  void _goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(cartItems: widget.cartItems),
      ),
    );
  }

  Widget _buildListItem(
      String name, dynamic price, String imageUrl, String ownerId, String equipmentId) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _safeImage(imageUrl),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text("RM $price / day",
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_shopping_cart),
          color: Colors.green,
          onPressed: () {
            setState(() {
              widget.cartItems.add({
                'name': name,
                'price': price,
                'category': 'Accessories',
                'ownerId': ownerId,
                'equipmentId': equipmentId,
              });
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$name added to cart"),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _safeImage(String? url) {
    if (url == null || url.isEmpty || !url.startsWith("http")) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.image_not_supported, color: Colors.white),
      );
    }

    return Image.network(
      url,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.broken_image, color: Colors.white),
        );
      },
    );
  }
}
