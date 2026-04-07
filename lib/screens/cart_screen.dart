import 'package:flutter/material.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  CartScreen({required this.cartItems});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

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

      // 🛒 Body
      body: items.isEmpty
          ? Center(
              child: Text(
                "Cart is empty 😢",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Card(
                  margin: EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [

                        // 🍔 Icon
                        Icon(Icons.fastfood,
                            size: 40, color: Colors.orange),

                        SizedBox(width: 10),

                        // 📦 Product Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["name"],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text("₹${item["price"]}"),
                            ],
                          ),
                        ),

                        // ➕➖ Buttons
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => removeItem(item),
                                icon: Icon(Icons.remove,
                                    color: Colors.red),
                              ),
                              Text(
                                item["qty"].toString(),
                                style: TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                onPressed: () => addItem(item),
                                icon: Icon(Icons.add,
                                    color: Colors.green),
                              ),
                            ],
                          ),
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [

                  // 💰 Total
                  Text(
                    "Total: ₹${getTotalPrice()}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // 🚀 Checkout Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {

                      // 🧑 Dummy customer data (later Firebase থেকে আনবে)
                      String name = "Tapiul Miya";
                      String phone = "9876543210";
                      String address = "Kolkata, West Bengal";

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
                      style: TextStyle(color: Colors.orange),
                    ),
                  )
                ],
              ),
            )
          : null,
    );
  }
}