import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("My Orders"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("userId", isEqualTo: uid)
            .snapshots(), // 🔥 orderBy remove (no index issue)

        builder: (context, snapshot) {

          // 🔄 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ No Data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No orders yet 😢",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: orders.length,
            itemBuilder: (context, index) {

              final order =
                  orders[index].data() as Map<String, dynamic>;

              final items = order["items"] as List;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,

                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      // 🧾 Order Header
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Order",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              order["status"] ?? "Pending",
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 5),

                      // 💰 Amount
                      Text(
                        "Amount: ₹${order["totalAmount"]}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),

                      Text("Payment: ${order["paymentMethod"]}"),

                      const Divider(),

                      // 📦 Items
                      const Text(
                        "Items:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 5),

                      ...items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Text("${item["name"]}"),
                              Text("x${item["qty"]}"),
                            ],
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 8),

                      // 📍 Address
                      Text(
                        "📍 ${order["address"]}",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}