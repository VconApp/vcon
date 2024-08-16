import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePureScreen extends StatelessWidget {
  final String productID;

  HomePureScreen({required this.productID});

  Future<DocumentSnapshot> _getProductData(String productID) async {
    const maxAttempts = 3;
    const backoffFactor = 2;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await FirebaseFirestore.instance
            .collection('products')
            .doc('homeLiving')
            .collection('homePureCollection')
            .doc(productID)
            .get();
      } catch (e) {
        if (attempt == maxAttempts - 1) {
          rethrow; // Re-throw the exception after max attempts
        }
        await Future.delayed(Duration(
            seconds: (backoffFactor ^ attempt) * 2)); // Exponential backoff
      }
    }
    throw Exception('Failed to fetch product data after $maxAttempts attempts');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _getProductData(productID),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Product Detail'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Scaffold(
            appBar: AppBar(
              title: Text('Product Detail'),
            ),
            body:
                Center(child: Text("Something went wrong: ${snapshot.error}")),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Product Detail'),
            ),
            body: Center(child: Text("Product not found")),
          );
        }

        // Get the data
        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: Text(data['productName'] ?? 'Product Detail'),
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Display product images
                if (data['images'] != null && data['images'] is List)
                  SizedBox(
                    height: 200.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: (data['images'] as List).length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                            data['images'][index],
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                // Display other product details
                Text('Product Name: ${data['productName'] ?? 'N/A'}'),
                Text('Product ID: ${data['productID'] ?? 'N/A'}'),
                Text('Retail Price: \$${data['retailPrice'] ?? 'N/A'}'),
                Text('Sales Price: \$${data['salesPrice'] ?? 'N/A'}'),
                Text('Quantity: ${data['quantity'] ?? 'N/A'}'),
                SizedBox(height: 10),
                Text('Tagline: ${data['tagline'] ?? 'N/A'}'),
                SizedBox(height: 10),
                Text('Instructions: ${data['instructions'] ?? 'N/A'}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
