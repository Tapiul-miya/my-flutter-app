import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';

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

  final UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  @override
  void initState() {
    super.initState();
    getUpiApps();
  }

  void getUpiApps() async {
    apps = await _upiIndia.getAllUpiApps();
    setState(() {});
  }

  int getTotalPrice() {
    int total = 0;
    for (var item in widget.cartItems) {
      total += (item["qty"] as int) * (item["price"] as int);
    }
    return total;
  }

  // 🔥 Show UPI App chooser
  void showUpiApps(int amount) {

    if (apps == null || apps!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No UPI app found ❗")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          padding: EdgeInsets.all(10),
          children: apps!.map((app) {
            return ListTile(
              leading: Image.memory(app.icon, height: 40),
              title: Text(app.name),
              onTap: () {
                Navigator.pop(context);
                startTransaction(app, amount);
              },
            );
          }).toList(),
        );
      },
    );
  }

  // 💳 Start UPI Transaction
  Future<void> startTransaction(UpiApp app, int amount) async {

    final response = await _upiIndia.startTransaction(
      app: app,
      receiverUpiId: "yourupiid@upi", // ⚠️ change this
      receiverName: "My Shop",
      transactionRefId: "TXN${DateTime.now().millisecondsSinceEpoch}",
      transactionNote: "Order Payment",
      amount: amount.toDouble(),
    );

    checkPaymentStatus(response);
  }

  // ✅ Payment Result
  void checkPaymentStatus(UpiResponse response) {
    String status = response.status ?? "UNKNOWN";

    if (status == UpiPaymentStatus.SUCCESS) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Successful ✅")),
      );
    } else if (status == UpiPaymentStatus.SUBMITTED) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Pending ⏳")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Failed ❌")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPrice = getTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout"),
      ),

      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🧑 Customer Details
            Text(
              "Customer Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Card(
              child: Padding(
                padding: EdgeInsets.all(10),
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

            SizedBox(height: 15),

            // 📦 Order Summary
            Text(
              "Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

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

            Divider(),

            // 💰 Total
            Text(
              "Total: ₹$totalPrice",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            // 💳 Payment Option
            Text(
              "Payment Method",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            RadioListTile(
              title: Text("Cash on Delivery"),
              value: "COD",
              groupValue: paymentMethod,
              onChanged: (val) {
                setState(() {
                  paymentMethod = val.toString();
                });
              },
            ),

            RadioListTile(
              title: Text("UPI Payment"),
              value: "UPI",
              groupValue: paymentMethod,
              onChanged: (val) {
                setState(() {
                  paymentMethod = val.toString();
                });
              },
            ),

            SizedBox(height: 10),

            // 🚀 Place Order
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.all(15),
                ),
                onPressed: () {

                  if (paymentMethod == "COD") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Order placed with COD 🚀")),
                    );
                  } else {
                    showUpiApps(totalPrice); // 🔥 app chooser
                  }
                },
                child: Text("Place Order"),
              ),
            )
          ],
        ),
      ),
    );
  }
}