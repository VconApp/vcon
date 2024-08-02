import 'package:flutter/material.dart';

import 'package:vcon_3rdparty_auth/screens/collect_product.dart';
import 'package:vcon_3rdparty_auth/screens/my_products.dart';

class CollectionStatusScreen extends StatelessWidget {
  final List<bool> isSelected;

  const CollectionStatusScreen({required this.isSelected, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Status'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50.0),
          Container(
            color: Colors.grey[200], // Background color for the text
            padding: const EdgeInsets.all(8.0), // Padding around the text
            child: const Text(
              'Please choose which section to view.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 180),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 250, // Set a fixed width for the buttons
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to Collects Product screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CollectProductScreen(isSelected: [true, false, false]),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB73E3E),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Collection Facilitation',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 250, // Set the same fixed width for the second button
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to My Products screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyProductsScreen(isSelected: [true, false]),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD18080),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Product Collection Support',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
