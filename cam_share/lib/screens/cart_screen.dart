import 'package:flutter/material.dart';
import 'photography_screen.dart';
import 'videography_screen.dart';
import 'accessories_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartScreen({super.key, required this.cartItems});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _goToCategory(Map<String, dynamic> item) {
    final category = item['category'] ?? '';
    if (category == 'Photography') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PhotographyScreen(cartItems: widget.cartItems)));
    } else if (category == 'Videography') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => VideographyScreen(cartItems: widget.cartItems)));
    } else if (category == 'Accessories') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => AccessoriesScreen(cartItems: widget.cartItems)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = const Color(0xFF4A00E0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Cart", style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: widget.cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.cartItems.length,
              itemBuilder: (ctx, index) {
                final item = widget.cartItems[index];
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    setState(() {
                      widget.cartItems.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Item removed from cart")),
                    );
                  },
                  child: GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Cart Item Options"),
                          content: const Text("Choose an action for this item:"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _goToCategory(item);
                              },
                              child: const Text("Go to Category"),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  widget.cartItems.removeAt(index);
                                });
                                Navigator.pop(context);
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'] ?? "Unnamed Item",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text("RM ${item['price']} / day",
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: widget.cartItems.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
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
                    "Proceed to Checkout",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
    );
  }
}
