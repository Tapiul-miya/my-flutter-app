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
  List<UpiApplication>? apps;

  @override
  void initState() {
    super.initState();
    getUpiApps();
  }

  // ✅ সঠিক মেথড নেম: getInstalledUpiApps
  void getUpiApps() async {
    try {
      apps = await UpiPay.getInstalledUpiApps();
      setState(() {});
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

  // 🔥 UPI App chooser UI
  void showUpiApps(int amount) {
    if (apps == null || apps!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No UPI app found ❗")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Choose Payment App", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: apps!.length,
                  itemBuilder: (context, index) {
                    final app = apps![index];
                    return ListTile(
                      leading: Icon(Icons.account_balance_wallet, color: Colors.blue),
                      title: Text(app.getAppName()),
                      onTap: () {
                        Navigator.pop(context);
                        startTransaction(app, amount);
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

  // 💳 সঠিক মেথড নেম: initiatePayment
  Future<void> startTransaction(UpiApplication app, int amount) async {
    try {
      final response = await UpiPay.initiatePayment(
        app: app,
        receiverUpiAddress: "yourupiid@upi", // ⚠️ আপনার UPI ID দিন
        receiverName: "My Shop",
        transactionRef: "TXN${DateTime.now().millisecondsSinceEpoch}",
        transactionNote: "Order Payment",
        amount: amount.toStringAsFixed(2),
      );

      checkPaymentStatus(response.status);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // ✅ Payment Result handling
  void checkPaymentStatus(UpiTransactionStatus? status) {
    if (status == UpiTransactionStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Successful ✅"), backgroundColor: Colors.green),
      );
    } else if (status == UpiTransactionStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Failed ❌"), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Cancelled/Pending ⏳")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPrice = getTotalPrice();

    return Scaffold(
      appBar: AppBar(title: Text("Checkout")),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Customer Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            Text("Total: ₹$totalPrice", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile(
              title: Text("Cash on Delivery"),
              value: "COD",
              groupValue: paymentMethod,
              onChanged: (val) => setState(() => paymentMethod = val.toString()),
            ),
            RadioListTile(
              title: Text("UPI Payment"),
              value: "UPI",
              groupValue: paymentMethod,
              onChanged: (val) => setState(() => paymentMethod = val.toString()),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: EdgeInsets.all(15)),
                onPressed: () {
                  if (paymentMethod == "COD") {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order placed with COD 🚀")));
                  } else {
                    showUpiApps(totalPrice);
                  }
                },
                child: Text("Place Order", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
