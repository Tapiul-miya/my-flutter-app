import 'package:flutter/material.dart';

void main() {
  runApp(const ZomatoProfessionalApp());
}

class ZomatoProfessionalApp extends StatelessWidget {
  const ZomatoProfessionalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto', // প্রফেশনাল ফন্ট
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE23744),
          primary: const Color(0xFFE23744),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                // লোকেশন এবং প্রোফাইল সেকশন
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFFE23744), size: 28),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                          Text('Salt Lake, Sector V, Kolkata...', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // প্রফেশনাল সার্চ বার
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Restaurant name or a dish...",
                    prefixIcon: Icon(Icons.search, color: Color(0xFFE23744)),
                    suffixIcon: Icon(Icons.mic, color: Color(0xFFE23744)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // অফার ব্যানার (Horizontal)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text("In the Spotlight", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            _buildOfferBanner(),

            const SizedBox(height: 25),

            // রেস্টুরেন্ট লিস্ট
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text("182 restaurants delivering to you", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            
            // স্যাম্পল রেস্টুরেন্ট কার্ড
            _buildRestaurantCard(
              "Arsalan Biryani", 
              "Biryani, North Indian, Mughlai", 
              "4.5", "30 mins", 
              "https://unsplash.com"
            ),
            _buildRestaurantCard(
              "Wow! Momo", 
              "Momos, Fast Food, Tibetan", 
              "4.2", "20 mins", 
              "https://unsplash.com"
            ),
          ],
        ),
      ),
    );
  }

  // অফার ব্যানার উইজেট
  Widget _buildOfferBanner() {
    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: 3,
        itemBuilder: (context, index) => Container(
          width: 300,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(colors: [Color(0xFFE23744), Color(0xFFF05A66)]),
          ),
          child: const Center(
            child: Text("FLAT 50% OFF\nOn your first order", 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  // প্রফেশনাল রেস্টুরেন্ট কার্ড উইজেট
  Widget _buildRestaurantCard(String name, String tags, String rating, String time, String imgUrl) {
    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(imgUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(6)),
                      child: Text(rating, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tags, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    Text(time, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
