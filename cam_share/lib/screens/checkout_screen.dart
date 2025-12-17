import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'renter_pro_dashboard.dart';

class CheckoutScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;

  const CheckoutScreen({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    final Color accentColor = const Color(0xFF4A00E0);

    double totalPrice() {
      double total = 0;
      for (var item in cartItems) {
        final price = item['price'];
        if (price is num) {
          total += price.toDouble();
        } else if (price is String) {
          total += double.tryParse(price) ?? 0;
        }
      }
      return total;
    }

    Future<void> _confirmOrder() async {
      final now = Timestamp.now();
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) return;

      for (var item in cartItems) {
        // Fetch ownerId directly from the equipment listing
        String equipmentId = item['equipmentId'] ?? '';
        String ownerId = '';

        if (equipmentId.isNotEmpty) {
          final doc = await FirebaseFirestore.instance
              .collection("listings")
              .doc(equipmentId)
              .get();

          if (doc.exists) {
            ownerId = doc.data()?['ownerId'] ?? '';
          }
        }

        await FirebaseFirestore.instance.collection("booking_requests").add({
          "equipmentId": equipmentId,
          "equipmentName": item['name'] ?? '',
          "renterName": currentUser.displayName ?? "Unknown Renter",
          "renterId": currentUser.uid,
          "ownerId": ownerId,
          "date": now,
          "status": "Pending",
        });
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Order Placed"),
          content: const Text("Your order has been successfully placed!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const RenterProDashboard()),
                  (route) => false,
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Checkout",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: cartItems.isEmpty
            ? const Center(child: Text("Your cart is empty"))
            : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: cartItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return ListTile(
                          tileColor: const Color(0xFFF0F4F8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          leading: Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.white),
                          ),
                          title: Text(item['name'] ?? 'Unnamed Item'),
                          subtitle: Text("RM ${item['price'] ?? '0'} / day"),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Total: RM ${totalPrice().toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // Swipe-to-confirm widget
                  Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            "Swipe to Confirm Checkout",
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          child: Draggable(
                            axis: Axis.horizontal,
                            feedback: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.arrow_forward,
                                  color: Colors.white),
                            ),
                            childWhenDragging: Container(),
                            onDragEnd: (details) {
                              if (details.offset.dx > 150) {
                                _confirmOrder();
                              }
                            },
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.arrow_forward,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}
