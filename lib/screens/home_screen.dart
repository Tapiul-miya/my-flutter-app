import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🔹 User
  String userName = "Guest";

  // 🔹 Search + Category
  String searchQuery = "";
  String selectedCategory = "All";

  final List<String> categories = [
    "All",
    "Burger",
    "Pizza",
  ];

  // 🔹 Banner
  late PageController _pageController;
  int currentPage = 0;
  final List<Map<String, String>> banners = [
    {
      "image": "https://picsum.photos/400/200?1",
      "title": "Delicious Burger",
      "offer": "50% OFF"
    },
    {
      "image": "https://picsum.photos/400/200?2",
      "title": "Hot Pizza",
      "offer": "40% OFF"
    },
    {
      "image": "https://picsum.photos/400/200?3",
      "title": "Tasty Combo",
      "offer": "30% OFF"
    },
  ];

  // 🔹 Restaurants & Menu
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    fetchUser();

    // Auto scroll banner
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        if (currentPage < banners.length - 1) {
          currentPage++;
        } else {
          currentPage = 0;
        }
        _pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void fetchUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      setState(() {
        userName = doc["name"];
      });
    }
  }

  // ➕➖ Cart functions
  void addItem(Map<String, dynamic> item) {
    setState(() {
      item["qty"]++;
    });
  }

  void removeItem(Map<String, dynamic> item) {
    setState(() {
      if (item["qty"] > 0) item["qty"]--;
    });
  }

  int getTotalItems() {
    int total = 0;
    for (var res in restaurants) {
      for (var item in res["menu"]) {
        total += item["qty"] as int;
      }
    }
    return total;
  }

  int getTotalPrice() {
    int total = 0;
    for (var res in restaurants) {
      for (var item in res["menu"]) {
        total += (item["qty"] as int) * (item["price"] as int);
      }
    }
    return total;
  }

  List<Map<String, dynamic>> getCartItems() {
    List<Map<String, dynamic>> cart = [];
    for (var res in restaurants) {
      for (var item in res["menu"]) {
        if (item["qty"] > 0) cart.add(item);
      }
    }
    return cart;
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = getTotalItems();
    int totalPrice = getTotalPrice();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // 🔴 HEADER
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hello 👋",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Amar Dokan",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search food...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 🎯 BANNER
          SizedBox(
            height: 180,
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    itemCount: banners.length,
                    itemBuilder: (context, index) {
                      final banner = banners[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                banner["image"]!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "HOT OFFER",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              left: 15,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    banner["title"]!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    banner["offer"]!,
                                    style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(banners.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentPage == index ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentPage == index ? Colors.orange : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🍱 CATEGORY
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                String category = categories[index];
                bool isSelected = selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.orange),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.orange,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 📜 FOOD LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: restaurants.map((res) {
                List filteredMenu = (res["menu"] as List).where((item) {
                  final nameMatch = item["name"].toLowerCase().contains(searchQuery);
                  final categoryMatch = selectedCategory == "All"
                      ? true
                      : item["name"].toLowerCase().contains(selectedCategory.toLowerCase());
                  return nameMatch && categoryMatch;
                }).toList();

                if (filteredMenu.isEmpty) return const SizedBox();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        res["name"],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Column(
                      children: filteredMenu.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 6),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.fastfood, color: Colors.orange),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["name"],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text("₹${item["price"]}"),
                                  ],
                                ),
                              ),
                              item["qty"] == 0
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      onPressed: () => addItem(item),
                                      child: const Text("ADD"),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.orange),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            onPressed: () => removeItem(item),
                                            icon: const Icon(Icons.remove, color: Colors.orange),
                                          ),
                                          Text(item["qty"].toString()),
                                          IconButton(
                                            onPressed: () => addItem(item),
                                            icon: const Icon(Icons.add, color: Colors.orange),
                                          ),
                                        ],
                                      ),
                                    )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),

      // 🛒 CART BAR
      bottomNavigationBar: totalItems > 0
          ? Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$totalItems items | ₹$totalPrice",
                    style: const TextStyle(color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CartScreen(
                            cartItems: getCartItems(),
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "VIEW CART",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
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