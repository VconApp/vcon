import 'package:flutter/material.dart';

class OrderCardCompletedMyProducts extends StatelessWidget {
  final String collectionID;
  final String collectorIRID;
  final String collectorName;
  final String orderId; 
  final List<Map<String, dynamic>> products;
  //final bool isSelected;

  const OrderCardCompletedMyProducts({
    required this.collectionID,
    required this.collectorIRID,
    required this.collectorName,
    required this.orderId,
    required this.products,
    //required this.isSelected,
    superkey
  });

  @override
  Widget build(BuildContext context) {
    // Group products by orderID
    Map<String, List<Map<String, dynamic>>> groupedProducts = {};
    for (var product in products) {
      String orderID = product['orderID'] ?? orderId;
      if (!groupedProducts.containsKey(orderID)) {
        groupedProducts[orderID] = [];
      } 
      groupedProducts[orderID]!.add(product);
    } 

    return Card(
      margin: const EdgeInsets.all(10),
      color: const Color.fromARGB(255, 194, 230, 187),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CollectionID: $collectionID'),
            Text('Collector IRID: $collectorIRID'),
            Text('Collector Name: $collectorName'),
            const SizedBox(height: 10),
            ...groupedProducts.entries.map((entry) => _buildOrderCard(context, entry.key, entry.value)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, String orderID, List<Map<String, dynamic>> orderProducts) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Card(
          color: const Color.fromARGB(226, 128, 209, 151),
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OrderID: $orderID'),
                const SizedBox(height: 5),
                ...orderProducts.map((product) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product ID: ${product['productID']}'),
                    Text('Product Name: ${product['productName']}'),
                    Text('Quantity: ${product['quantity']}'),
                    const SizedBox(height: 10),
                  ],
                )).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





