// FULL CODE (COMPLETE - NOTHING MISSING)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'my_orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String userName = "Guest";

  String searchQuery = "";
  String selectedCategory = "All";
  List<String> categories = ["All"];

  List<Map<String, dynamic>> restaurants = [];
  List<Map<String, dynamic>> banners = [];

  bool isLoading = true;

  late PageController _pageController;
  int currentPage = 0;
  Timer? bannerTimer;
  
  
  
 
  

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    fetchUser();
    fetchRestaurants();

    bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_pageController.hasClients && banners.isNotEmpty) {
        currentPage = (currentPage + 1) % banners.length;

        _pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    bannerTimer?.cancel();
    super.dispose();
  }

  // 👤 USER
  void fetchUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      setState(() {
        userName = doc.data()?["name"] ?? "User";
      });
    }
  }

  // 🔥 FETCH DATA (FIXED)
  Future<void> fetchRestaurants() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection("restaurants").get();

      List<Map<String, dynamic>> loadedRestaurants = [];
      List<Map<String, dynamic>> loadedBanners = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // ✅ FIX: items collection
        final itemSnap = await FirebaseFirestore.instance
            .collection("restaurants")
            .doc(doc.id)
            .collection("items")
            .get();

        List<Map<String, dynamic>> menuList = [];

        for (var item in itemSnap.docs) {
          final itemData = item.data();

          menuList.add({
  "name": itemData["name"] ?? "",
  "price": itemData["offerPrice"] ?? itemData["price"] ?? 0,
  "image": itemData["image"] ?? "",
  "category": itemData["category"] ?? "", // ✅ ADD
  "isVeg": itemData["isVeg"] ?? true,     // ✅ ADD (optional but useful)
  "qty": 0,
});
          
          
        }

        // 🔥 BANNERS
        final bannerSnap = await FirebaseFirestore.instance
            .collection("restaurants")
            .doc(doc.id)
            .collection("banners")
            .get();

        for (var bannerDoc in bannerSnap.docs) {
          final bannerData = bannerDoc.data();

          if ((bannerData["image"] ?? "").toString().isNotEmpty) {
            loadedBanners.add({
              "title": bannerData["title"] ?? "",
              "offer": bannerData["offer"] ?? "",
              "image": bannerData["image"] ?? "",
            });
          }
        }

        loadedRestaurants.add({
          "name": data["name"] ?? "",
          "category": data["category"] ?? "",
          "menu": menuList,
        });
      }

      setState(() {
        restaurants = loadedRestaurants;
        banners = loadedBanners;

        Set<String> allCategories = {"All"};

for (var res in loadedRestaurants) {
  for (var item in res["menu"]) {
    String cat = (item["category"] ?? "").toString();

    if (cat.isNotEmpty) {
      allCategories.add(cat);
    }
  }
}

categories = allCategories.toList();
                
                
                

        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  // 🛒 CART
  void addItem(Map<String, dynamic> item) {
    setState(() => item["qty"]++);
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

  // 🔥 SAFE IMAGE
  Widget safeImage(String url) {
    if (url.toString().startsWith("http")) {
      return Image.network(
        url,
        height: 70,
        width: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image),
      );
    } else {
      return const Icon(Icons.image, size: 60);
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                      const Text("Hello 👋",
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(userName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Amar Dokan",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProfileScreen()),
                      );
                    },
                    child: const CircleAvatar(
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
                setState(() => searchQuery = value.toLowerCase());
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




          // 🎯 BANNER SLIDER (PRO VERSION)
if (banners.isNotEmpty)
  SizedBox(
    height: 190,
    child: PageView.builder(
      controller: _pageController,
      itemCount: banners.length,
      onPageChanged: (index) {
        setState(() => currentPage = index);
      },
      itemBuilder: (context, index) {
        final banner = banners[index];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [

                // 🖼️ IMAGE
                Image.network(
                  banner["image"],
                  fit: BoxFit.cover,
                ),

                // 🌑 DARK GRADIENT OVERLAY
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.75),
                        Colors.black.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                ),

                // 🎯 CONTENT
                Positioned(
                  bottom: 18,
                  left: 18,
                  right: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // 🟡 OFFER BADGE (HIGHLIGHT)
                      Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFFF8C00), Color(0xFFFF3D00)],
    ),
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.local_offer, color: Colors.white, size: 14),
      const SizedBox(width: 4),
      Text(
        banner["offer"].toString().toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    ],
  ),
),

                      const SizedBox(height: 6),

                      // 🏷️ TITLE (BIG + BOLD)
                      Text(
                        banner["title"],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ✨ SUBTEXT (OPTIONAL STYLE)
                      const Text(
                        "Limited time offer 🔥",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔘 PAGE INDICATOR (DOTS)
                Positioned(
                  bottom: 10,
                  right: 15,
                  child: Row(
                    children: List.generate(
                      banners.length,
                      (dotIndex) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: currentPage == dotIndex ? 10 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: currentPage == dotIndex
                              ? Colors.orange
                              : Colors.white54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                final category = categories[index];
                final isSelected = selectedCategory == category;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedCategory = category);
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
              
              
              
              
              
              children: (() {

  // 🔥 GROUP BY CATEGORY
  Map<String, List<Map<String, dynamic>>> groupedItems = {};

  for (var res in restaurants) {
    for (var item in res["menu"]) {

      String category = (item["category"] ?? "").toString();

      final nameMatch =
          item["name"].toLowerCase().contains(searchQuery);

      final categoryMatch = selectedCategory == "All"
          ? true
          : category.toLowerCase() ==
              selectedCategory.toLowerCase();

      if (nameMatch && categoryMatch) {
        groupedItems.putIfAbsent(category, () => []);
        groupedItems[category]!.add(item);
      }
    }
  }

  return groupedItems.entries.map((entry) {

    String categoryName = entry.key;
    List items = entry.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // 🔥 🔴 ONLY CHANGE: Restaurant → Category
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            categoryName, // 👈 এখানেই change
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),

        Column(
          children: items.map((item) {

            // 🔥 EXACT SAME CARD DESIGN (UNCHANGED)
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [

                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: item["image"].toString().startsWith("http")
                        ? Image.network(
                            item["image"],
                            height: 85,
                            width: 85,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image, size: 80),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 10,
                              color: (item["isVeg"] ?? true)
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              "Best Seller",
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          item["name"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          item["category"] ?? "",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: const [
                            Icon(Icons.star,
                                size: 14,
                                color: Colors.orange),
                            SizedBox(width: 3),
                            Text("4.3",
                                style: TextStyle(fontSize: 12)),
                            SizedBox(width: 8),
                            Text("• 20 min",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey)),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Text(
                              "₹${item["price"]}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "₹${(item["price"] * 1.3).toInt()}",
                              style: const TextStyle(
                                fontSize: 12,
                                decoration:
                                    TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  item["qty"] == 0
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          onPressed: () => addItem(item),
                          child: const Text("ADD"),
                        )
                      : Row(
                          children: [
                            IconButton(
                                onPressed: () => removeItem(item),
                                icon: const Icon(Icons.remove)),
                            Text(item["qty"].toString()),
                            IconButton(
                                onPressed: () => addItem(item),
                                icon: const Icon(Icons.add)),
                          ],
                        ),
                ],
              ),
            );

          }).toList(),
        ),
      ],
    );
  }).toList();

})(),
              
              
              
              
              
              
              
            ),
          ),
        ],
      ),
      
      
      
      
      
      
      
      
      
      

      // 🔻 BOTTOM BAR
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          if (totalItems > 0)
            Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text("$totalItems items | ₹$totalPrice",
                      style: const TextStyle(color: Colors.white)),
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
                    child: const Text("VIEW CART",
                        style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),

          Container(
            height: 36,
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            child: Row(
              children: [

                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Text("Close",
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyOrdersScreen(),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Text("My Orders",
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}