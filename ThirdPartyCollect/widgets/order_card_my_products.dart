//order_card_my_products.dart
import 'package:flutter/material.dart';

class OrderCardMyProducts extends StatelessWidget {
  final String date;
  final String orderId;
  final String irId;
  final int quantity;
  final String productId;
  final String productName;

  const OrderCardMyProducts({
    required this.date,
    required this.orderId,
    required this.irId,
    required this.quantity,
    required this.productId,
    required this.productName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the card width based on the constraints of the parent widget
        // For example, use 90% of the available width or a maximum of 800 pixels
        final double cardWidth = constraints.maxWidth * 0.9 > 800 ? 800 : constraints.maxWidth * 0.9;

        return Center(
          child: SizedBox(
            width: cardWidth,
            child: Card(
              color: const Color(0xFFD18080),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Text('Order ID: $orderId', style: const TextStyle(color: Colors.black)),
                    Text('IR ID: $irId', style: const TextStyle(color: Colors.black)),
                    Text('Product ID: $productId', style: const TextStyle(color: Colors.black)),
                    Text('Product Name: $productName', style: const TextStyle(color: Colors.black)),
                    Text('Quantity: $quantity', style: const TextStyle(color: Colors.black)),
                    const SizedBox(height: 10),
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
 