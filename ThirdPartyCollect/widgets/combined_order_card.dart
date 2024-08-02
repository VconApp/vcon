import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CombinedOrderCard extends StatelessWidget {
  final String collectionID;
  final String collectorIRID;
  final String collectorName;
  final String orderId;
  final List<Map<String, dynamic>> products;
  final VoidCallback onChangeCollector;
  final Function(String, List<String>) onOrderReceived;
  final bool isSelected;
  final String orderStatus;
  final Function(String, String, String, Timestamp)
      navigateToChangeCollectorScreen;

  const CombinedOrderCard({
    Key? key,
    required this.collectionID,
    required this.collectorIRID,
    required this.collectorName,
    required this.orderId,
    required this.products,
    required this.onChangeCollector,
    required this.onOrderReceived,
    required this.isSelected,
    required this.orderStatus,
    required this.navigateToChangeCollectorScreen,
  }) : super(key: key);

  void _showCollectedStatusAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Cannot Change Collector'),
        content: const Text('The order has already been collected.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

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

    // Extract order IDs
    List<String> orderIDs = groupedProducts.keys.toList();

    return Card(
      margin: const EdgeInsets.all(10),
      color: const Color.fromARGB(255, 233, 198, 198),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CollectionID: $collectionID'),
            Text('Collector IRID: $collectorIRID'),
            Text('Collector Name: $collectorName'),
            const SizedBox(height: 10),
            ...groupedProducts.entries.map(
                (entry) => _buildOrderCard(context, entry.key, entry.value)),
            const SizedBox(height: 20),
            if (isSelected)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: orderStatus == 'Collected'
                        ? () => _showCollectedStatusAlert(context)
                        : onChangeCollector,
                    child: const Text('Change Collector'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (orderIDs.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('No order IDs available')),
                        );
                        return;
                      }
                      print(
                          "onOrderReceived called with collectionID: $collectionID, orderIds: $orderIDs");
                      onOrderReceived(collectionID, orderIDs);
                    },
                    child: const Text('Order Received'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, String orderID,
      List<Map<String, dynamic>> orderProducts) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Card(
          color: const Color(0xFFD18080),
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OrderID: $orderID'),
                const SizedBox(height: 5),
                ...orderProducts
                    .map((product) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Product ID: ${product['productID']}'),
                            Text('Product Name: ${product['productName']}'),
                            Text('Quantity: ${product['quantity']}'),
                            const SizedBox(height: 10),
                          ],
                        ))
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 









// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class CombinedOrderCard extends StatelessWidget {
//   final String collectionID;
//   final String collectorIRID;
//   final String collectorName;
//   final String orderId; 
//   final List<Map<String, dynamic>> products;
//   final VoidCallback onChangeCollector;
//   final VoidCallback onOrderReceived;
//   final bool isSelected;
//   final Function(String, String, String, Timestamp) navigateToChangeCollectorScreen;

//   const CombinedOrderCard({
//     required this.collectionID,
//     required this.collectorIRID,
//     required this.collectorName,
//     required this.orderId,
//     required this.products,
//     required this.onChangeCollector,
//     required this.onOrderReceived,
//     required this.isSelected,
//     required this.navigateToChangeCollectorScreen,
//     superkey
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Card(
//         margin: const EdgeInsets.all(10),
//         color: const Color.fromARGB(255, 233, 198, 198),
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('CollectionID: $collectionID'),
//               Text('Collector IRID: $collectorIRID'),
//               Text('Collector Name: $collectorName'),
//               const SizedBox(height: 10),
//               Center(
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.8,
//                   child: Card(
//                     color: const Color(0xFFD18080),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: products.map((product) => Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('OrderID: ${product['orderID']}'),
//                             Text('Product ID: ${product['productID']}'),
//                             Text('Product Name: ${product['productName']}'),
//                             Text('Quantity: ${product['quantity']}'),
//                             const SizedBox(height: 10),
//                           ],
//                         )).toList(),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               if (isSelected)
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         if (products.isNotEmpty) {
//                           navigateToChangeCollectorScreen(
//                             orderId,
//                             collectorIRID,
//                             collectorName,
//                             products[0]['authorizeTimestamp'] ?? Timestamp.now(),
//                           );
//                         }
//                       },
//                       child: const Text('Change Collector'),
//                     ),
//                     const SizedBox(width: 10),
//                     ElevatedButton(
//                       onPressed: onOrderReceived,
//                       child: const Text('Order Received'),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }