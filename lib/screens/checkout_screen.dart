import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_success_screen.dart';

enum PaymentMethod { cod, online }
enum PaymentApp { phonepe, gpay, paytm }

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final String name;
  final String phone;
  final String address;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.name,
    required this.phone,
    required this.address,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {

  PaymentMethod selectedMethod = PaymentMethod.cod;
  PaymentApp? selectedApp;

  bool loading = false;

  final int deliveryFee = 40;

  int getSubtotal() {
    int total = 0;
    for (var item in widget.cartItems) {
      total += (item["qty"] as int) * (item["price"] as int);
    }
    return total;
  }

  // 🔥 Save Order
  Future<void> placeOrder(int totalAmount) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection("orders").add({
      "userId": uid,
      "name": widget.name,
      "phone": widget.phone,
      "address": widget.address,
      "items": widget.cartItems,
      "totalAmount": totalAmount,
      "paymentMethod":
          selectedMethod == PaymentMethod.cod ? "COD" : "ONLINE",
      "isPaid": selectedMethod == PaymentMethod.online,
      "status": "Pending",
      "createdAt": Timestamp.now(),
    });
  }

  // 🔥 Open Payment App
  Future<void> openPayment(int amount) async {
    String url = "";

    switch (selectedApp) {
      case PaymentApp.phonepe:
        url = "phonepe://pay?pa=tapiul@ybl&pn=MyShop&am=$amount&cu=INR";
        break;
      case PaymentApp.gpay:
        url = "tez://upi/pay?pa=tapiul@ybl&pn=MyShop&am=$amount&cu=INR";
        break;
      case PaymentApp.paytm:
        url = "paytmmp://pay?pa=tapiul@ybl&pn=MyShop&am=$amount&cu=INR";
        break;
      default:
        return;
    }

    await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
  }

  // 🔥 Place Order Action
  Future<void> handleOrder(int total) async {

    if (selectedMethod == PaymentMethod.online && selectedApp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select payment app ❗")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await placeOrder(total);

      if (selectedMethod == PaymentMethod.online) {
        await openPayment(total);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(
              orderId: DateTime.now()
                  .millisecondsSinceEpoch
                  .toString(),
              amount: total,
              isPaid: selectedMethod == PaymentMethod.online,
            ),
          ),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order failed ❗")),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    int subtotal = getSubtotal();
    int total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Checkout"),
        centerTitle: true,
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: loading ? null : () => handleOrder(total),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: loading
                ? const CircularProgressIndicator(
                    color: Colors.white)
                : Text(
                    "Place Order • ₹$total",
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [

            // 👤 User Info
            _sectionCard(
              child: ListTile(
                leading: const Icon(Icons.person,
                    color: Colors.orange),
                title: Text(widget.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                subtitle: Text(
                    "${widget.phone}\n${widget.address}"),
              ),
            ),

            const SizedBox(height: 15),

            // 🛒 Items
            _sectionTitle("Order Items"),

            ...widget.cartItems.map((item) {
              if (item["qty"] == 0) return SizedBox();

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.fastfood,
                      color: Colors.orange),
                  title: Text(item["name"]),
                  subtitle: Text("Qty: ${item["qty"]}"),
                  trailing: Text(
                    "₹${item["price"] * item["qty"]}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),

            const SizedBox(height: 15),

            // 💰 Price
            _sectionCard(
              child: Column(
                children: [
                  _priceRow("Subtotal", subtotal),
                  _priceRow("Delivery", deliveryFee),
                  const Divider(),
                  _priceRow("Total", total, bold: true),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 💳 Payment
            _sectionTitle("Payment Method"),

            RadioListTile(
              value: PaymentMethod.cod,
              groupValue: selectedMethod,
              onChanged: (v) =>
                  setState(() => selectedMethod = v!),
              title: const Text("Cash on Delivery"),
            ),

            RadioListTile(
              value: PaymentMethod.online,
              groupValue: selectedMethod,
              onChanged: (v) =>
                  setState(() => selectedMethod = v!),
              title: const Text("Online Payment"),
            ),

            if (selectedMethod == PaymentMethod.online) ...[
              _paymentOption("PhonePe", PaymentApp.phonepe),
              _paymentOption("Google Pay", PaymentApp.gpay),
              _paymentOption("Paytm", PaymentApp.paytm),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // 🔹 Widgets

  Widget _sectionCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: child,
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 8, color: Colors.orange),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ],
    );
  }

  Widget _priceRow(String title, int value,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            "₹$value",
            style: TextStyle(
              fontWeight:
                  bold ? FontWeight.bold : FontWeight.normal,
              color: bold ? Colors.orange : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOption(String title, PaymentApp app) {
    return RadioListTile(
      value: app,
      groupValue: selectedApp,
      onChanged: (v) => setState(() => selectedApp = v),
      title: Text(title),
    );
  }
}