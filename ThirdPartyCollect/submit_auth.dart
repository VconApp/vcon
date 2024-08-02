import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> submitAuth({
  required String collectionID,
  required String collectorName,
  required String collectorIRID,
  required String authorizerName,
  required String authorizerIRID, 
  required List<Map<String, dynamic>> orders, // List of orders to be updated
  required String authStatus,
  required String orderStatus,
  required String orderReceived,
}) async { 
  try {
    // Combine all orders into a single list of order items
    List<Map<String, dynamic>> ordersData = [];

    // for (var order in orders) {
    //   ordersData.add({
    //     'orderID': order['orderID'],
    //     'purchaseDate': order['purchaseDate'],
    //     'products': order['orders'],
    //   });
    //   //combinedOrders.addAll(order['orders']);
    // }

    for (var order in orders) {
      // Ensure that 'products' is always an array, even for a single product
      List<Map<String, dynamic>> products;
      if (order['orders'] is List) {
        products = List<Map<String, dynamic>>.from(order['orders']);
      } else if (order['orders'] is Map) {
        products = [Map<String, dynamic>.from(order['orders'])];
      } else {
        throw Exception('Invalid order format');
      }

      ordersData.add({
        'orderID': order['orderID'],
        'purchaseDate': order['purchaseDate'],
        'products': products,
      });
    }

    // Add a single entry to ThirdPartyCollect
    await FirebaseFirestore.instance.collection('ThirdPartyCollect').add({
      'collectionID': collectionID,
      'collectorName': collectorName,
      'collectorIRID': collectorIRID,
      'purchaserName': authorizerName,
      'purchaserIRID': authorizerIRID,
      'orders': ordersData,
      'authorizationStatus': authStatus,
      'orderStatus': orderStatus,
      'orderReceived': orderReceived,
      'authorizeTimestamp': FieldValue.serverTimestamp(),
    });

    // Update each order in the Orders collection
    for (var order in orders) {
      String orderID = order['orderID'];

      // Find the document by orderID and update the assignStatus
      QuerySnapshot orderQuerySnapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where('orderID', isEqualTo: orderID)
          .where('assignStatus', isEqualTo: 'Unassigned') // Ensure only unassigned orders are updated
          .get();

      if (orderQuerySnapshot.docs.isNotEmpty) {
        // Assuming the orderID is unique, get the first document
        DocumentSnapshot orderDocument = orderQuerySnapshot.docs.first;
        String documentID = orderDocument.id;

        // Update the document with the given document ID
        await FirebaseFirestore.instance
            .collection('Orders')
            .doc(documentID)
            .update({
          'assignStatus': 'Assigned', // Update the assignStatus to Assigned
        });
      } else {
        throw Exception('Order with orderID $orderID not found or already assigned.');
      }
    }
    print('Orders submitted successfully.');
  } catch (error) {
    print('Failed to submit orders: $error');
    throw error;
  }
}

