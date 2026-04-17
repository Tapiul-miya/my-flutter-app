import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  CartScreen({required this.cartItems});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  String name = "";
  String phone = "";
  String address = "";

  bool loadingUser = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // 🔥 Firestore থেকে user data আনা
  Future<void> fetchUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      if (doc.exists) {
        setState(() {
          name = doc["name"] ?? "";
          phone = doc["mobile"] ?? "";
          address = doc["address"] ?? "";
          loadingUser = false;
        });
      }
    } catch (e) {
      print("User load error: $e");
      setState(() => loadingUser = false);
    }
  }

  // ➕ Increase Qty
  void addItem(Map<String, dynamic> item) {
    setState(() {
      item["qty"]++;
    });
  }

  // ➖ Decrease Qty
  void removeItem(Map<String, dynamic> item) {
    setState(() {
      if (item["qty"] > 0) {
        item["qty"]--;
      }
    });
  }

  // 💰 Total Price
  int getTotalPrice() {
    int total = 0;
    for (var item in widget.cartItems) {
      total += (item["qty"] as int) * (item["price"] as int);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final items =
        widget.cartItems.where((item) => item["qty"] > 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
        centerTitle: true,
      ),

      body: items.isEmpty
          ? Center(
              child: Text("Cart is empty 😢"),
            )
          : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Card(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.fastfood,
                            size: 40, color: Colors.orange),
                        SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["name"],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("₹${item["price"]}"),
                            ],
                          ),
                        ),

                        Row(
                          children: [
                            IconButton(
                              onPressed: () => removeItem(item),
                              icon: Icon(Icons.remove,
                                  color: Colors.red),
                            ),
                            Text(item["qty"].toString()),
                            IconButton(
                              onPressed: () => addItem(item),
                              icon: Icon(Icons.add,
                                  color: Colors.green),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),

      // 🔥 Bottom Bar
      bottomNavigationBar: items.isNotEmpty
          ? Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: loadingUser
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total: ₹${getTotalPrice()}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () {

                            // 🔥 Firebase data pass হচ্ছে এখানে
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(
                                  cartItems: widget.cartItems,
                                  name: name,
                                  phone: phone,
                                  address: address,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "Checkout",
                            style: TextStyle(
                              color: Colors.orange,
                            ),
                          ),
                        )
                      ],
                    ),
            )
          : null,
    );
  }
}