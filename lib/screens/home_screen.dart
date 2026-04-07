import 'package:flutter/material.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final List<Map<String, dynamic>> restaurants = [
    {
      "name": "Burger King",
      "menu": [
        {"name": "Chicken Burger", "price": 120, "qty": 0},
        {"name": "Cheese Burger", "price": 150, "qty": 0},
      ]
    },
    {
      "name": "Pizza Hut",
      "menu": [
        {"name": "Veg Pizza", "price": 200, "qty": 0},
        {"name": "Chicken Pizza", "price": 250, "qty": 0},
      ]
    },
  ];

  // ➕ Add item
  void addItem(Map<String, dynamic> item) {
    setState(() {
      item["qty"]++;
    });
  }

  // ➖ Remove item
  void removeItem(Map<String, dynamic> item) {
    setState(() {
      if (item["qty"] > 0) {
        item["qty"]--;
      }
    });
  }

  // 📦 Total items
  int getTotalItems() {
    int total = 0;
    for (var res in restaurants) {
      for (var item in res["menu"]) {
        total += item["qty"] as int;
      }
    }
    return total;
  }

  // 💰 Total price
  int getTotalPrice() {
    int total = 0;
    for (var res in restaurants) {
      for (var item in res["menu"]) {
        total += (item["qty"] as int) * (item["price"] as int);
      }
    }
    return total;
  }

  // 🛒 Cart list
  List<Map<String, dynamic>> getCartItems() {
    List<Map<String, dynamic>> cart = [];

    for (var res in restaurants) {
      for (var item in res["menu"]) {
        if (item["qty"] > 0) {
          cart.add(item);
        }
      }
    }

    return cart;
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = getTotalItems();
    int totalPrice = getTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: Text("Food Delivery"),
        centerTitle: true,
      ),

      body: ListView(
        padding: EdgeInsets.all(10),
        children: restaurants.map((res) {

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🏪 Restaurant Name
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  res["name"],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 🍔 Menu List
              Column(
                children: (res["menu"] as List).map((item) {

                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 5),
                      ],
                    ),
                    child: Row(
                      children: [

                        // Icon
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.fastfood, color: Colors.orange),
                        ),

                        SizedBox(width: 12),

                        // Name + Price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["name"],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text("₹${item["price"]}"),
                            ],
                          ),
                        ),

                        // 🔥 Add / +/- Button
                        item["qty"] == 0
                            ? ElevatedButton(
                                onPressed: () => addItem(item),
                                child: Text("Add"),
                              )
                            : Row(
                                children: [
                                  IconButton(
                                    onPressed: () => removeItem(item),
                                    icon: Icon(Icons.remove_circle, color: Colors.red),
                                  ),
                                  Text(
                                    item["qty"].toString(),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    onPressed: () => addItem(item),
                                    icon: Icon(Icons.add_circle, color: Colors.green),
                                  ),
                                ],
                              )
                      ],
                    ),
                  );

                }).toList(),
              ),

              SizedBox(height: 10),
            ],
          );

        }).toList(),
      ),

      // 🛒 Bottom Cart Bar
      bottomNavigationBar: totalItems > 0
          ? Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange,
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 5),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$totalItems items | ₹$totalPrice",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CartScreen(
                            cartItems: getCartItems(),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "View Cart",
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