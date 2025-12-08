import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart'; 

class PhotographyScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const PhotographyScreen({super.key, required this.cartItems});

  @override
  State<PhotographyScreen> createState() => _PhotographyScreenState();
}

class _PhotographyScreenState extends State<PhotographyScreen> {
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
        title: const Text("Photography",
            style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            CartScreen(cartItems: widget.cartItems)),
                  );
                },
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
          stream: FirebaseFirestore.instance.collection('listings').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No equipment available"));
            }

            final items = snapshot.data!.docs;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (ctx, i) => const SizedBox(height: 16),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final item = items[i];
                return _buildListItem(
                  item['name'] ?? "Unnamed Item",
                  item['price'] ?? 0,
                  () {
                    setState(() {
                      widget.cartItems.add({
                        'name': item['name'] ?? "Unnamed Item",
                        'price': item['price'] ?? 0,
                      });
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${item['name']} added to cart"),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: widget.cartItems.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CheckoutScreen(cartItems: widget.cartItems),
                        ),
                      );
                    },
              child: const Text(
                "Checkout",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
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
        ],
      ),
    );
  }

  Widget _buildListItem(String name, dynamic price, VoidCallback onAddToCart) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
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
          onPressed: onAddToCart,
        ),
      ],
    );
  }
}
