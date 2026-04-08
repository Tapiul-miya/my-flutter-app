import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  final int deliveryFee = 40;

  int getSubtotal() {
    int total = 0;
    for (var item in widget.cartItems) {
      total += (item["qty"] as int) * (item["price"] as int);
    }
    return total;
  }

  Future<void> openSelectedApp(int amount) async {
    String url = "";

    switch (selectedApp) {
      case PaymentApp.phonepe:
        url = "phonepe://pay?pa=tapiul@ybl&pn=My Shop&am=$amount&cu=INR";
        break;
      case PaymentApp.gpay:
        url = "tez://upi/pay?pa=tapiul@ybl&pn=My Shop&am=$amount&cu=INR";
        break;
      case PaymentApp.paytm:
        url = "paytmmp://pay?pa=tapiul@ybl&pn=My Shop&am=$amount&cu=INR";
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select payment app ❗")),
        );
        return;
    }

    try {
      await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("App open hocche na ❗")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int subtotal = getSubtotal();
    int grandTotal = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        centerTitle: true,
      ),

      /// 🔥 Bottom Fixed Button (NO OVERFLOW)
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: Text("Place Order • ₹$grandTotal"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (selectedMethod == PaymentMethod.cod) {
                
                Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => OrderSuccessScreen(
      orderId: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: grandTotal,
      isPaid: selectedMethod == PaymentMethod.online,
    ),
  ),
);
                
                
              } else {
                openSelectedApp(grandTotal);
              }
            },
          ),
        ),
      ),

      /// 🔥 Scrollable Body (NO OVERFLOW)
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [

              /// 🔹 Customer Info
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ListTile(
                  leading:
                      const Icon(Icons.person, color: Colors.orange),
                  title: Text(widget.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(widget.phone),
                      Text(widget.address),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// 🔹 Order Summary
              Row(
                children: const [
                  Icon(Icons.shopping_cart,
                      color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Order Summary",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: widget.cartItems.length,
                itemBuilder: (_, index) {
                  final item = widget.cartItems[index];

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: const Icon(Icons.fastfood,
                          color: Colors.orange),
                      title: Text(item["name"]),
                      subtitle:
                          Text("Qty: ${item["qty"]}"),
                      trailing: Text(
                        "₹${item["price"] * item["qty"]}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              /// 🔹 Price Breakdown
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Subtotal"),
                        Text("₹$subtotal"),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Delivery Fee"),
                        Text("₹$deliveryFee"),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Grand Total",
                            style: TextStyle(
                                fontWeight:
                                    FontWeight.bold)),
                        Text(
                          "₹$grandTotal",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              /// 🔹 Payment Method
              Row(
                children: const [
                  Icon(Icons.payment,
                      color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Payment Method",
                      style: TextStyle(
                          fontWeight: FontWeight.bold)),
                ],
              ),

              RadioListTile(
                value: PaymentMethod.cod,
                groupValue: selectedMethod,
                onChanged: (val) =>
                    setState(() => selectedMethod = val!),
                title: const Text("Cash on Delivery"),
                secondary: const Icon(Icons.money),
              ),

              RadioListTile(
                value: PaymentMethod.online,
                groupValue: selectedMethod,
                onChanged: (val) =>
                    setState(() => selectedMethod = val!),
                title: const Text("Online Payment"),
                secondary: const Icon(Icons.qr_code),
              ),

              if (selectedMethod == PaymentMethod.online) ...[
                RadioListTile(
                  value: PaymentApp.phonepe,
                  groupValue: selectedApp,
                  onChanged: (val) =>
                      setState(() => selectedApp = val),
                  title: const Text("PhonePe"),
                  secondary:
                      const Icon(Icons.phone_android),
                ),
                RadioListTile(
                  value: PaymentApp.gpay,
                  groupValue: selectedApp,
                  onChanged: (val) =>
                      setState(() => selectedApp = val),
                  title: const Text("Google Pay"),
                  secondary: const Icon(
                      Icons.account_balance),
                ),
                RadioListTile(
                  value: PaymentApp.paytm,
                  groupValue: selectedApp,
                  onChanged: (val) =>
                      setState(() => selectedApp = val),
                  title: const Text("Paytm"),
                  secondary: const Icon(Icons.wallet),
                ),
              ],

              const SizedBox(height: 80), // 🔥 space for button
            ],
          ),
        ),
      ),
    );
  }
}