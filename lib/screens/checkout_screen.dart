import 'package:flutter/material.dart';
import 'package:upi_pay/upi_pay.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final String name;
  final String phone;
  final String address;

  CheckoutScreen({
    required this.cartItems,
    required this.name,
    required this.phone,
    required this.address,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String paymentMethod = "COD";
  
  // ১. মেথডগুলো Static নয়, তাই instance তৈরি করা হয়েছে
  final _upiPay = UpiPay(); 
  
  // ২. টাইপ List<ApplicationMeta> করা হয়েছে
  List<ApplicationMeta>? apps; 

  @override
  void initState() {
    super.initState();
    getUpiApps();
  }

  void getUpiApps() async {
    try {
      final List<ApplicationMeta> installedApps = await _upiPay.getInstalledUpiApplications();
      setState(() {
        apps = installedApps;
      });
    } catch (e) {
      debugPrint("Error fetching UPI apps: $e");
    }
  }

  int getTotalPrice() {
    int total = 0;
    for (var item in widget.cartItems) {
      total += (item["qty"] as int) * (item["price"] as int);
    }
    return total;
  }

  void showUpiApps(int amount) {
    if (apps == null || apps!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No UPI app found ❗")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Choose Payment App", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: apps!.length,
                  itemBuilder: (context, index) {
                    final appMeta = apps![index];
                    return ListTile(
                      leading: const Icon(Icons.account_balance_wallet, color: Colors.blue),
                      title: Text(appMeta.upiApplication.getAppName()),
                      onTap: () {
                        Navigator.pop(context);
                        startTransaction(appMeta.upiApplication, amount);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> startTransaction(UpiApplication app, int amount) async {
    try {
      // ৩. এখানে 'initiatePayment' বদলে 'initiateTransaction' করা হয়েছে
      final response = await _upiPay.initiateTransaction(
        app: app,
        receiverUpiAddress: "yourupiid@upi", // ⚠️ আপনার আসল UPI ID দিন
        receiverName: "My Shop",
        transactionRef: "TXN${DateTime.now().millisecondsSinceEpoch}",
        transactionNote: "Order Payment",
        amount: amount.toDouble().toStringAsFixed(2),
      );

      checkPaymentStatus(response.status);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void checkPaymentStatus(UpiTransactionStatus? status) {
    if (status == UpiTransactionStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Successful ✅"), backgroundColor: Colors.green),
      );
    } else if (status == UpiTransactionStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Failed ❌"), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Cancelled/Pending ⏳")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPrice = getTotalPrice();
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Customer Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: ${widget.name}"),
                    Text("Phone: ${widget.phone}"),
                    Text("Address: ${widget.address}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return ListTile(
                    title: Text(item["name"]),
                    subtitle: Text("Qty: ${item["qty"]}"),
                    trailing: Text("₹${item["price"] * item["qty"]}"),
                  );
                },
              ),
            ),
            const Divider(),
            Text("Total: ₹$totalPrice", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile(
              title: const Text("Cash on Delivery"),
              value: "COD",
              groupValue: paymentMethod,
              onChanged: (val) => setState(() => paymentMethod = val.toString()),
            ),
            RadioListTile(
              title: const Text("UPI Payment"),
              value: "UPI",
              groupValue: paymentMethod,
              onChanged: (val) => setState(() => paymentMethod = val.toString()),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.all(15)),
                onPressed: () {
                  if (paymentMethod == "COD") {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order placed with COD 🚀")));
                  } else {
                    showUpiApps(totalPrice);
                  }
                },
                child: const Text("Place Order", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
