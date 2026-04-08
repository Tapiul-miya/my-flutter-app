import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final int amount;
  final bool isPaid;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.isPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                /// 🎉 Success Icon
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                ),

                const SizedBox(height: 25),

                /// ✅ Title
                const Text(
                  "Order Placed Successfully!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                /// 📦 Subtitle
                Text(
                  isPaid
                      ? "Your payment was successful 🎉"
                      : "Pay when your order arrives 🚚",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                /// 🧾 Order Details Card
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [

                        /// Order ID
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Order ID"),
                            Text(
                              orderId,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// Amount
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Amount"),
                            Text(
                              "₹$amount",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// 🔥 Payment Status
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Payment Status"),
                            Text(
                              isPaid ? "Paid ✅" : "Due ❗",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isPaid
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔙 Continue Shopping Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text("Continue Shopping"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.popUntil(
                          context, (route) => route.isFirst);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}