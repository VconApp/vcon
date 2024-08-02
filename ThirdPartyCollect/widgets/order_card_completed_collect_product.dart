import 'package:flutter/material.dart';

class OrderCardCompletedCollectProduct extends StatelessWidget {
  final String date;
  final String orderId;
  final String irId;
  final int quantity;
  final VoidCallback onDetails;

  const OrderCardCompletedCollectProduct({
    required this.date,
    required this.orderId,
    required this.irId,
    required this.quantity,
    required this.onDetails,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final double cardWidth = constraints.maxWidth * 0.8 > 800 ? 800 : constraints.maxWidth * 0.8;

      return Center(
        child: SizedBox(
          width: cardWidth,
          child: Card(
            color: const Color.fromARGB(226, 128, 209, 151),
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ID: $orderId'),
                  const SizedBox(height: 5),
                  Text('IR ID: $irId'),
                  const SizedBox(height: 5),
                  Text('Quantity: $quantity'),
                  const SizedBox(height: 5),
                  Text('Date: $date'),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: onDetails,
                      child: const Text('Details'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
}