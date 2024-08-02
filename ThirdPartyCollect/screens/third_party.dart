// //third_party.dart
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:logger/logger.dart';
// import 'package:get/get.dart';
// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:uuid/uuid.dart';
// import 'dart:math';

// import 'package:vcon_3rdparty_auth/screens/submit_success.dart';
// import 'package:vcon_3rdparty_auth/submit_auth.dart';
// import 'package:vcon_3rdparty_auth/auth_controller.dart';

// class ThirdPartyDetailsScreen extends StatefulWidget {
//   const ThirdPartyDetailsScreen({super.key});

//   @override
//   State<ThirdPartyDetailsScreen> createState() => _ThirdPartyDetailsScreenState();
// }

// class _ThirdPartyDetailsScreenState extends State<ThirdPartyDetailsScreen> {
//   //final TextEditingController _irIdController = TextEditingController();
//   final TextEditingController _collectorIrIdController = TextEditingController();
//   String _collectorName = '';
//   String _collectorIRID = '';
//   String _authorizerName = '';
//   //String _authorizerIRID = '';
//   String _orderID = '';
//   String? _selectedOrderID;
//   List<String> _orderIDs = [];
//   DateTime? _purchaseDate;
//   List<Map<String, dynamic>> _orders = [];
//   String _errorMessage = '';
//   bool _isLoading = false;
//   bool _isAssigned = false;

//   // Create logger instance
//   final Logger logger = Logger();

//   //varaible to store authorizerIRID
//   late String authorizerIRID;

//   //final Uuid _uuid = Uuid();

//   @override
//   void initState() {
//     super.initState();
//     _collectorIrIdController.addListener(_onCollectorIDChanged);
//     authorizerIRID = Get.find<AuthController>().authorizerIRID.value;
//     _fetchOrderData(authorizerIRID);
//   }

//   @override
//   void dispose() {
//     _collectorIrIdController.removeListener(_onCollectorIDChanged);
//     _collectorIrIdController.dispose();
//     super.dispose();
//   }

//   void _onCollectorIDChanged() {
//     var collectorID = _collectorIrIdController.text.trim();
//     if (collectorID.isNotEmpty) {
//       _validateAndFetchCollector(collectorID);
//     } else {
//       setState(() {
//         _collectorName = '';
//         _collectorIRID = '';
//         _errorMessage = '';
//       });
//     }
//   }

//   Future<void> _fetchOrderData(String userIRID) async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       QuerySnapshot orderQuerySnapshot = await FirebaseFirestore.instance
//           .collection('Orders')
//           .where('irID', isEqualTo: userIRID.trim())
//           .where('assignStatus', isEqualTo: 'Unassigned')
//           .get();

//       if (orderQuerySnapshot.docs.isNotEmpty) {
//         List<Map<String, dynamic>> allOrders = [];

//         for (var orderDocument in orderQuerySnapshot.docs) {
//           var orderData = orderDocument.data() as Map<String, dynamic>;

//           String orderID = orderData['orderID'] ?? '';
//           DateTime purchaseDate = (orderData['purchaseDate'] as Timestamp).toDate();

//             List<Map<String, dynamic>> orders = [];
//             orderData['orders'].forEach((key, value) {
//               orders.add({
//                 'productID': value['productID'] ?? '',
//                 'productName': value['productName'] ?? '',
//                 'quantity': value['quantity'] ?? 0,
//               });
//             });

//             allOrders.add({
//               'orderID': orderID,
//               'purchaseDate': purchaseDate,
//               'orders': orders,
//             });
//         }

//         setState(() {
//           _orders = allOrders;
//           _authorizerName = orderQuerySnapshot.docs.first['irName'] ?? '';
//           _orderID = orderQuerySnapshot.docs.first['orderID'] ?? '';
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _orders = [];
//           _errorMessage = 'No purchases found for this IRID.';
//           _isLoading = false;
//         });
//       }
//     } catch (error) {
//       setState(() {
//         _orders = [];
//         _errorMessage = 'Error fetching data: $error';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _validateAndFetchCollector(String collectorID) async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       if (collectorID.trim() == authorizerIRID) {
//         setState(() {
//           _collectorName = '';
//           _collectorIRID = '';
//           _errorMessage = 'You cannot assign yourself as a collector.';
//           _isLoading = false;
//         });
//         return;
//       }

//       QuerySnapshot irQuerySnapshot = await FirebaseFirestore.instance
//           .collection('IR')
//           .where('irID', isEqualTo: collectorID.trim())
//           .get();

//       if (irQuerySnapshot.docs.isNotEmpty) {
//         var irDocument = irQuerySnapshot.docs.first;
//         var irData = irDocument.data() as Map<String, dynamic>;

//         String irName = irData['irName'] ?? '';

//         setState(() {
//           _collectorName = irName.isEmpty ? 'Collector name not available' : irName;
//           _collectorIRID = collectorID;
//           _errorMessage = '';
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _collectorName = '';
//           _collectorIRID = '';
//           _errorMessage = 'No user found with IRID: $collectorID';
//           _isLoading = false;
//         });
//       }
//     } catch (error) {
//       setState(() {
//         _collectorName = '';
//         _collectorIRID = '';
//         _errorMessage = 'Error fetching collector: $error';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> sendNotificationToCollector(String collectorIRID, String message) async {
//     try {
//       HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendNotification');
//       final result = await callable.call({
//         'collectorIRID': collectorIRID,
//         'message': message,
//       });
//       print("Notification sent: ${result.data}");
//     } catch (e) {
//       print("Error sending notification: $e");
//     }
//   }

//   String generateCollectionID(int length) {
//     const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
//     Random random = Random();
//     return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join('');
//   }

//   Widget _buildProductTable() {
//     final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

//     return ListView.builder(
//       shrinkWrap: true,
//       itemCount: _orders.length,
//       itemBuilder: (context, index) {
//         var order = _orders[index];
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Order ID: ${order['orderID']}',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'Purchase Date: ${formatter.format(order['purchaseDate'])}',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Table(
//               border: TableBorder.all(color: Colors.black),
//               children: [
//                 const TableRow(
//                   decoration: BoxDecoration(color: Color.fromARGB(255, 155, 49, 49)),
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text(
//                         'Product ID',
//                         style: TextStyle(
//                           fontWeight: FontWeight.normal,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text(
//                         'Product Name',
//                         style: TextStyle(
//                           fontWeight: FontWeight.normal,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text(
//                         'Quantity',
//                         style: TextStyle(
//                           fontWeight: FontWeight.normal,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 for (var product in order['orders'])
//                   TableRow(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(product['productID'] ?? ''),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(product['productName'] ?? ''),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(product['quantity'].toString()),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//             const SizedBox(height: 20), // Space between different orders
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     //final String collectionID = generateCollectionID(12);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Third Party Product Collection'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 16),
//             if (!_isAssigned)
//               Container(
//                 color: const Color.fromARGB(255, 225, 110, 85),
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const Text(
//                           'IR ID: ',
//                           style: TextStyle(
//                             color: Colors.white,
//                             height: 2.5,
//                           ),
//                         ),
//                         Text(
//                           authorizerIRID,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             height: 2.5,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Text(
//                       'List of Products: ',
//                       style: TextStyle(
//                         color: Colors.white,
//                         height: 2.5,
//                       ),
//                     ),
//                     _buildProductTable(),
//                   ],
//                 ),
//               ),
//             const SizedBox(height: 35),
//             if (!_isAssigned)
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(
//                     width: 190, // Set a fixed width for the label text
//                     child: Text(
//                       'Enter Collector IR ID:',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: SizedBox(
//                       height: 35, // Set the desired height
//                       child: TextField(
//                         controller: _collectorIrIdController,
//                         decoration: const InputDecoration(
//                           labelText: 'Enter IR ID',
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(
//                               vertical: 10.0), // Adjust padding for height
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             const SizedBox(height: 25),
//             const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Collector\'s Information',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (_isLoading) const CircularProgressIndicator(),
//             if (!_isLoading && _errorMessage.isNotEmpty)
//               Text(
//                 'Collector Name: $_errorMessage',
//                 style: const TextStyle(color: Colors.red),
//               ),
//             if (!_isLoading && _errorMessage.isEmpty)
//               Text(
//                 'Collector Name: $_collectorName',
//                 style: const TextStyle(color: Colors.black),
//               ),
//             if (!_isLoading && _errorMessage.isEmpty)
//               Text(
//                 'Collector IR ID: $_collectorIRID',
//                 style: const TextStyle(color: Colors.black),
//               ),
//             const SizedBox(height: 35),
//             if (!_isAssigned)
//               Center(
//                 child: ElevatedButton(
//                   onPressed: _errorMessage.isNotEmpty
//                       ? null
//                       : () async {
//                           if (_collectorName.isNotEmpty &&
//                               _collectorIRID.isNotEmpty) {
//                             try {
//                               //// Generate a unique collection ID using the current timestamp and authorizerIRID
//                               //String collectionID = DateTime.now().millisecondsSinceEpoch.toString() + '_${Get.find<AuthController>().authorizerIRID.value}';
//                               String collectionID = generateCollectionID(12);
//                               // Call the submitAuth function
//                               await submitAuth(
//                                 collectionID: collectionID,
//                                 collectorName: _collectorName,
//                                 collectorIRID: _collectorIRID,
//                                 authorizerName: _authorizerName,
//                                 authorizerIRID: authorizerIRID,
//                                 orders: _orders,
//                                 authStatus: 'Pending',
//                                 orderStatus: 'Uncollected',
//                                 orderReceived: 'No'
//                               );
//                               //Refresh the list of orders
//                               await _fetchOrderData(authorizerIRID);
//                               // Mark as assigned and clear order details
//                               setState(() {
//                                 _isAssigned = true;
//                                 _orders = [];
//                                 _orderID = '';
//                                 _purchaseDate = null;
//                                 _collectorIrIdController.clear();
//                               });
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       const SubmitSuccessScreen(),
//                                 ),
//                               ).then((_) {
//                                 Navigator.pop(context); //pops the ThirdPartyDetailsScreen
//                               });

//                                await sendNotificationToCollector(
//                                 _collectorIRID,
//                                 "You have been assigned a new collection task.",
//                               );

//                               setState(() {
//                                 _isAssigned = true;
//                                 _orders = [];
//                                 _orderID = '';
//                                 _purchaseDate = null;
//                                 _collectorIrIdController.clear();
//                               });
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const SubmitSuccessScreen(),
//                                 ),
//                               ).then((_) {
//                                 Navigator.pop(context);
//                               });

//                             } catch (e) {

//                               setState(() {
//                                 _errorMessage = 'Failed to submit order: $e';
//                               });
//                             }
//                           } else {
//                             setState(() {
//                               _errorMessage =
//                                   'Please enter a valid IR ID and ensure collector details are fetched.';
//                             });
//                           }
//                         },
//                   child: const Text(
//                     'CONFIRM',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 17,
//                       height: 1.5,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// blaze_third_party.dart
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:logger/logger.dart';
// import 'package:get/get.dart';
// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:uuid/uuid.dart';
// import 'dart:math';

// import 'package:vcon_3rdparty_auth/screens/submit_success.dart';
// import 'package:vcon_3rdparty_auth/submit_auth.dart';
// import 'package:vcon_3rdparty_auth/auth_controller.dart';

// class ThirdPartyDetailsScreen extends StatefulWidget {
//   const ThirdPartyDetailsScreen({super.key});

//   @override
//   State<ThirdPartyDetailsScreen> createState() =>
//       _ThirdPartyDetailsScreenState();
// }

// class _ThirdPartyDetailsScreenState extends State<ThirdPartyDetailsScreen> {
//   //final TextEditingController _irIdController = TextEditingController();
//   final TextEditingController _collectorIrIdController =
//       TextEditingController();
//   String _collectorName = '';
//   String _collectorIRID = '';
//   String _authorizerName = '';
//   //String _authorizerIRID = '';
//   String _orderID = '';
//   String? _selectedOrderID;
//   List<String> _orderIDs = [];
//   DateTime? _purchaseDate;
//   List<Map<String, dynamic>> _orders = [];
//   String _errorMessage = '';
//   bool _isLoading = false;
//   bool _isAssigned = false;

//   // Create logger instance
//   final Logger logger = Logger();

//   //varaible to store authorizerIRID
//   late String authorizerIRID;

//   //final Uuid _uuid = Uuid();

//   @override
//   void initState() {
//     super.initState();
//     _collectorIrIdController.addListener(_onCollectorIDChanged);
//     authorizerIRID = Get.find<AuthController>().authorizerIRID.value;
//     _fetchOrderData(authorizerIRID);
//   }

//   @override
//   void dispose() {
//     _collectorIrIdController.removeListener(_onCollectorIDChanged);
//     _collectorIrIdController.dispose();
//     super.dispose();
//   }

//   void _onCollectorIDChanged() {
//     var collectorID = _collectorIrIdController.text.trim();
//     if (collectorID.isNotEmpty) {
//       _validateAndFetchCollector(collectorID);
//     } else {
//       setState(() {
//         _collectorName = '';
//         _collectorIRID = '';
//         _errorMessage = '';
//       });
//     }
//   }

//   Future<void> _fetchOrderData(String userIRID) async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       QuerySnapshot orderQuerySnapshot = await FirebaseFirestore.instance
//           .collection('Orders')
//           .where('irID', isEqualTo: userIRID.trim())
//           .where('assignStatus', isEqualTo: 'Unassigned')
//           .get();

//       if (orderQuerySnapshot.docs.isNotEmpty) {
//         List<Map<String, dynamic>> allOrders = [];

//         for (var orderDocument in orderQuerySnapshot.docs) {
//           var orderData = orderDocument.data() as Map<String, dynamic>;

//           String orderID = orderData['orderID'] ?? '';
//           DateTime purchaseDate =
//               (orderData['purchaseDate'] as Timestamp).toDate();

//           List<Map<String, dynamic>> orders = [];
//           orderData['orders'].forEach((key, value) {
//             orders.add({
//               'productID': value['productID'] ?? '',
//               'productName': value['productName'] ?? '',
//               'quantity': value['quantity'] ?? 0,
//             });
//           });

//           allOrders.add({
//             'orderID': orderID,
//             'purchaseDate': purchaseDate,
//             'orders': orders,
//           });
//         }

//         setState(() {
//           _orders = allOrders;
//           _authorizerName = orderQuerySnapshot.docs.first['irName'] ?? '';
//           _orderID = orderQuerySnapshot.docs.first['orderID'] ?? '';
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _orders = [];
//           _errorMessage = 'No purchases found for this IRID.';
//           _isLoading = false;
//         });
//       }
//     } catch (error) {
//       setState(() {
//         _orders = [];
//         _errorMessage = 'Error fetching data: $error';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _validateAndFetchCollector(String collectorID) async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       if (collectorID.trim() == authorizerIRID) {
//         setState(() {
//           _collectorName = '';
//           _collectorIRID = '';
//           _errorMessage = 'You cannot assign yourself as a collector.';
//           _isLoading = false;
//         });
//         return;
//       }

//       QuerySnapshot irQuerySnapshot = await FirebaseFirestore.instance
//           .collection('IR')
//           .where('irID', isEqualTo: collectorID.trim())
//           .get();

//       if (irQuerySnapshot.docs.isNotEmpty) {
//         var irDocument = irQuerySnapshot.docs.first;
//         var irData = irDocument.data() as Map<String, dynamic>;

//         String irName = irData['irName'] ?? '';

//         setState(() {
//           _collectorName =
//               irName.isEmpty ? 'Collector name not available' : irName;
//           _collectorIRID = collectorID;
//           _errorMessage = '';
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _collectorName = '';
//           _collectorIRID = '';
//           _errorMessage = 'No user found with IRID: $collectorID';
//           _isLoading = false;
//         });
//       }
//     } catch (error) {
//       setState(() {
//         _collectorName = '';
//         _collectorIRID = '';
//         _errorMessage = 'Error fetching collector: $error';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _saveNotification(
//       String collectorIRID, String authorizerName) async {
//     try {
//       DocumentReference docRef =
//           await FirebaseFirestore.instance.collection('notifications').add({
//         'body':
//             'You have been assigned a new collection task by $authorizerName.',
//         'irID': collectorIRID,
//         'timestamp': FieldValue.serverTimestamp(),
//         'title': 'New Collection Task Assigned',
//         'type': 'collect_products',
//       });
//       print('Notification saved successfully. Document ID: ${docRef.id}');
//     } catch (e) {
//       print('Error saving notification: $e');
//     }
//   }

//   Future<void> sendNotificationToCollector(
//       String collectorIRID, String message, String authorizerName) async {
//     try {
//       HttpsCallable callable =
//           FirebaseFunctions.instance.httpsCallable('sendNotification');
//       final result = await callable.call({
//         'collectorIRID': collectorIRID,
//         'message': '$message by $authorizerName.',
//       });
//       print("Notification sent: ${result.data}");
//     } catch (e) {
//       print("Error sending notification: $e");
//     }
//   }

//   String generateCollectionID(int length) {
//     const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
//     Random random = Random();
//     return List.generate(length, (index) => chars[random.nextInt(chars.length)])
//         .join('');
//   }

//   Widget _buildProductTable() {
//     final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

//     return ListView.builder(
//       shrinkWrap: true,
//       itemCount: _orders.length,
//       itemBuilder: (context, index) {
//         var order = _orders[index];
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Order ID: ${order['orderID']}',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'Purchase Date: ${formatter.format(order['purchaseDate'])}',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Table(
//               border: TableBorder.all(color: Colors.black),
//               children: [
//                 const TableRow(
//                   decoration:
//                       BoxDecoration(color: Color.fromARGB(255, 155, 49, 49)),
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text(
//                         'Product ID',
//                         style: TextStyle(
//                           fontWeight: FontWeight.normal,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text(
//                         'Product Name',
//                         style: TextStyle(
//                           fontWeight: FontWeight.normal,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text(
//                         'Quantity',
//                         style: TextStyle(
//                           fontWeight: FontWeight.normal,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 for (var product in order['orders'])
//                   TableRow(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(product['productID'] ?? ''),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(product['productName'] ?? ''),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(product['quantity'].toString()),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//             const SizedBox(height: 20), // Space between different orders
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     //final String collectionID = generateCollectionID(12);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Third Party Product Collection'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 16),
//             if (!_isAssigned)
//               Container(
//                 color: const Color.fromARGB(255, 225, 110, 85),
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const Text(
//                           'IR ID: ',
//                           style: TextStyle(
//                             color: Colors.white,
//                             height: 2.5,
//                           ),
//                         ),
//                         Text(
//                           authorizerIRID,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             height: 2.5,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Text(
//                       'List of Products: ',
//                       style: TextStyle(
//                         color: Colors.white,
//                         height: 2.5,
//                       ),
//                     ),
//                     _buildProductTable(),
//                   ],
//                 ),
//               ),
//             const SizedBox(height: 35),
//             if (!_isAssigned)
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(
//                     width: 190, // Set a fixed width for the label text
//                     child: Text(
//                       'Enter Collector IR ID:',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: SizedBox(
//                       height: 35, // Set the desired height
//                       child: TextField(
//                         controller: _collectorIrIdController,
//                         decoration: const InputDecoration(
//                           labelText: 'Enter IR ID',
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(
//                               vertical: 10.0), // Adjust padding for height
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             const SizedBox(height: 25),
//             const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Collector\'s Information',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (_isLoading) const CircularProgressIndicator(),
//             if (!_isLoading && _errorMessage.isNotEmpty)
//               Text(
//                 'Collector Name: $_errorMessage',
//                 style: const TextStyle(color: Colors.red),
//               ),
//             if (!_isLoading && _errorMessage.isEmpty)
//               Text(
//                 'Collector Name: $_collectorName',
//                 style: const TextStyle(color: Colors.black),
//               ),
//             if (!_isLoading && _errorMessage.isEmpty)
//               Text(
//                 'Collector IR ID: $_collectorIRID',
//                 style: const TextStyle(color: Colors.black),
//               ),
//             const SizedBox(height: 35),
//             if (!_isAssigned)
//               Center(
//                 child: ElevatedButton(
//                   onPressed: _errorMessage.isNotEmpty
//                       ? null
//                       : () async {
//                           if (_collectorName.isNotEmpty &&
//                               _collectorIRID.isNotEmpty) {
//                             try {
//                               //// Generate a unique collection ID using the current timestamp and authorizerIRID
//                               //String collectionID = DateTime.now().millisecondsSinceEpoch.toString() + '_${Get.find<AuthController>().authorizerIRID.value}';
//                               String collectionID = generateCollectionID(12);
//                               // Call the submitAuth function
//                               await submitAuth(
//                                   collectionID: collectionID,
//                                   collectorName: _collectorName,
//                                   collectorIRID: _collectorIRID,
//                                   authorizerName: _authorizerName,
//                                   authorizerIRID: authorizerIRID,
//                                   orders: _orders,
//                                   authStatus: 'Pending',
//                                   orderStatus: 'Uncollected',
//                                   orderReceived: 'No');
//                               //Refresh the list of orders
//                               await _fetchOrderData(authorizerIRID);

//                               String message =
//                                   "You have been assigned a new collection task";

//                               await sendNotificationToCollector(
//                                 _collectorIRID,
//                                 message,
//                                 _authorizerName,
//                               );

//                               await _saveNotification(
//                                   _collectorIRID, _authorizerName);
//                               // Mark as assigned and clear order details
//                               setState(() {
//                                 _isAssigned = true;
//                                 _orders = [];
//                                 _orderID = '';
//                                 _purchaseDate = null;
//                                 _collectorIrIdController.clear();
//                               });
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       const SubmitSuccessScreen(),
//                                 ),
//                               ).then((_) {
//                                 Navigator.pop(
//                                     context); //pops the ThirdPartyDetailsScreen
//                               });
//                             } catch (e) {
//                               setState(() {
//                                 _errorMessage = 'Failed to submit order: $e';
//                               });
//                             }
//                           } else {
//                             setState(() {
//                               _errorMessage =
//                                   'Please enter a valid IR ID and ensure collector details are fetched.';
//                             });
//                           }
//                         },
//                   child: const Text(
//                     'CONFIRM',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 17,
//                       height: 1.5,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// //fcm_third_party.dart
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:logger/logger.dart';
// import 'package:get/get.dart';
// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:uuid/uuid.dart';
// import 'dart:math';
// import 'package:firebase_messaging/firebase_messaging.dart';

// import 'package:vcon_3rdparty_auth/screens/submit_success.dart';
// import 'package:vcon_3rdparty_auth/submit_auth.dart';
// import 'package:vcon_3rdparty_auth/auth_controller.dart';

// class ThirdPartyDetailsScreen extends StatefulWidget {
//   const ThirdPartyDetailsScreen({super.key});

//   @override
//   State<ThirdPartyDetailsScreen> createState() =>
//       _ThirdPartyDetailsScreenState();
// }

// class _ThirdPartyDetailsScreenState extends State<ThirdPartyDetailsScreen> {
//   //final TextEditingController _irIdController = TextEditingController();
//   final TextEditingController _collectorIrIdController =
//       TextEditingController();
//   String _collectorName = '';
//   String _collectorIRID = '';
//   String _authorizerName = '';
//   //String _authorizerIRID = '';
//   String _orderID = '';
//   String? _selectedOrderID;
//   List<String> _orderIDs = [];
//   DateTime? _purchaseDate;
//   List<Map<String, dynamic>> _orders = [];
//   String _errorMessage = '';
//   bool _isLoading = false;
//   bool _isAssigned = false;

//   // Create logger instance
//   final Logger logger = Logger();

//   //varaible to store authorizerIRID
//   late String authorizerIRID;

//   //final Uuid _uuid = Uuid();

//   @override
//   void initState() {
//     super.initState();
//     _collectorIrIdController.addListener(_onCollectorIDChanged);
//     authorizerIRID = Get.find<AuthController>().authorizerIRID.value;
//     _fetchOrderData(authorizerIRID);
//     initializeFCMAndSaveToken();
//     // testFcmTokenRetrieval('KNOWN_COLLECTOR_IRID');
//   }

//   @override
//   void dispose() {
//     _collectorIrIdController.removeListener(_onCollectorIDChanged);
//     _collectorIrIdController.dispose();
//     super.dispose();
//   }

//   void _onCollectorIDChanged() {
//     var collectorID = _collectorIrIdController.text.trim();
//     if (collectorID.isNotEmpty) {
//       _validateAndFetchCollector(collectorID);
//     } else {
//       setState(() {
//         _collectorName = '';
//         _collectorIRID = '';
//         _errorMessage = '';
//       });
//     }
//   }

//   Future<void> _fetchOrderData(String userIRID) async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       QuerySnapshot orderQuerySnapshot = await FirebaseFirestore.instance
//           .collection('Orders')
//           .where('irID', isEqualTo: userIRID.trim())
//           .where('assignStatus', isEqualTo: 'Unassigned')
//           .get();

//       if (orderQuerySnapshot.docs.isNotEmpty) {
//         List<Map<String, dynamic>> allOrders = [];

//         for (var orderDocument in orderQuerySnapshot.docs) {
//           var orderData = orderDocument.data() as Map<String, dynamic>;

//           String orderID = orderData['orderID'] ?? '';
//           DateTime purchaseDate =
//               (orderData['purchaseDate'] as Timestamp).toDate();

//           List<Map<String, dynamic>> orders = [];
//           orderData['orders'].forEach((key, value) {
//             orders.add({
//               'productID': value['productID'] ?? '',
//               'productName': value['productName'] ?? '',
//               'quantity': value['quantity'] ?? 0,
//             });
//           });

//           allOrders.add({
//             'orderID': orderID,
//             'purchaseDate': purchaseDate,
//             'orders': orders,
//           });
//         }

//         setState(() {
//           _orders = allOrders;
//           _authorizerName = orderQuerySnapshot.docs.first['irName'] ?? '';
//           _orderID = orderQuerySnapshot.docs.first['orderID'] ?? '';
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _orders = [];
//           _errorMessage = 'No purchases found for this IRID.';
//           _isLoading = false;
//         });
//       }
//     } catch (error) {
//       setState(() {
//         _orders = [];
//         _errorMessage = 'Error fetching data: $error';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _validateAndFetchCollector(String collectorID) async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       if (collectorID.trim() == authorizerIRID) {
//         setState(() {
//           _collectorName = '';
//           _collectorIRID = '';
//           _errorMessage = 'You cannot assign yourself as a collector.';
//           _isLoading = false;
//         });
//         return;
//       }

//       QuerySnapshot irQuerySnapshot = await FirebaseFirestore.instance
//           .collection('IR')
//           .where('irID', isEqualTo: collectorID.trim())
//           .get();

//       if (irQuerySnapshot.docs.isNotEmpty) {
//         var irDocument = irQuerySnapshot.docs.first;
//         var irData = irDocument.data() as Map<String, dynamic>;

//         String irName = irData['irName'] ?? '';

//         setState(() {
//           _collectorName =
//               irName.isEmpty ? 'Collector name not available' : irName;
//           _collectorIRID = collectorID;
//           _errorMessage = '';
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _collectorName = '';
//           _collectorIRID = '';
//           _errorMessage = 'No user found with IRID: $collectorID';
//           _isLoading = false;
//         });
//       }
//     } catch (error) {
//       setState(() {
//         _collectorName = '';
//         _collectorIRID = '';
//         _errorMessage = 'Error fetching collector: $error';
//         _isLoading = false;
//       });
//     }
//   }
//   Future<void> saveFCMToken(String collectorIRID, String fcmToken) async {
//     try {
//       print('Saving FCM Token for collectorIRID: $collectorIRID');

//       // Create or update the document in the IR collection with the FCM token
//       await FirebaseFirestore.instance
//           .collection('IR')
//           .doc(collectorIRID)
//           .set({
//             'fcmToken': fcmToken,
//           }, SetOptions(merge: true)); // Merge with existing data if the document exists

//       print('FCM Token saved successfully for collectorIRID: $collectorIRID');
//     } catch (e) {
//       print('Error saving FCM Token: $e');
//     }
//   }

//   // Function to initialize FCM and save the token
//   void initializeFCMAndSaveToken() async {
//     try {
//       String? fcmToken = await FirebaseMessaging.instance.getToken();
//       if (fcmToken != null) {
//         print('FCM Token: $fcmToken');
//         await saveFCMToken(authorizerIRID, fcmToken);
//       } else {
//         print('Error: FCM Token is null');
//       }
//     } catch (e) {
//       print('Error fetching FCM Token: $e');
//     }
//   }

//   Future<void> _saveNotification(String collectorIRID, String authorizerName) async {
//   try {
//     print('Fetching collector document for collectorIRID: $collectorIRID');

//     // Fetch the collector's IR ID from the ThirdPartyCollect collection
//     DocumentSnapshot collectorDoc = await FirebaseFirestore.instance
//         .collection('ThirdPartyCollect')
//         .doc(collectorIRID)
//         .get();

//     // Check if the document exists
//     if (!collectorDoc.exists) {
//       print('Error: Collector document does not exist for collectorIRID: $collectorIRID');
//       return;
//     }

//     // Assuming there's an IR ID in the ThirdPartyCollect document
//     String collectorIRIDFromThirdParty = collectorDoc.get('irID');

//     // Fetch the FCM token from the IR collection using the IR ID
//     DocumentSnapshot irDoc = await FirebaseFirestore.instance
//         .collection('IR')
//         .doc(collectorIRIDFromThirdParty)
//         .get();

//     if (!irDoc.exists) {
//       print('Error: IR document does not exist for IR ID: $collectorIRIDFromThirdParty');
//       return;
//     }

//     String? fcmToken = irDoc.get('fcmToken');

//     if (fcmToken == null || fcmToken.isEmpty) {
//       print('Error: FCM token is not available for this IR ID');
//       return;
//     }

//     // Save the notification
//     DocumentReference docRef = await FirebaseFirestore.instance.collection('notifications').add({
//       'body': 'You have been assigned a new collection task by $authorizerName.',
//       'irID': collectorIRID,
//       'timestamp': FieldValue.serverTimestamp(),
//       'title': 'New Collection Task Assigned',
//       'type': 'collect_products',
//       'fcmToken': fcmToken, // Add the FCM token to the notification document
//     });

//     print('Notification saved successfully. Document ID: ${docRef.id}');
//   } catch (e) {
//     print('Error saving notification: $e');
//   }
// }

// Future<void> testFcmTokenRetrieval(String collectorIRID) async {
//   try {
//     DocumentSnapshot collectorDoc = await FirebaseFirestore.instance
//         .collection('IR')
//         .doc(collectorIRID)
//         .get();

//     if (!collectorDoc.exists) {
//       print('Error: Collector document does not exist');
//       return;
//     }

//     String? fcmToken = collectorDoc.get('fcmToken');
//     if (fcmToken == null || fcmToken.isEmpty) {
//       print('Error: FCM token is not available for this collector');
//       return;
//     }

//     print('FCM token for $collectorIRID: $fcmToken');
//   } catch (e) {
//     print('Error retrieving FCM token: $e');
//   }
// }

//   //cloud functions
//   // Future<void> sendNotificationToCollector(
//   //     String collectorIRID, String message, String authorizerName) async {
//   //   try {
//   //     HttpsCallable callable =
//   //         FirebaseFunctions.instance.httpsCallable('sendNotification');
//   //     final result = await callable.call({
//   //       'collectorIRID': collectorIRID,
//   //       'message': '$message by $authorizerName.',
//   //     });
//   //     print("Notification sent: ${result.data}");
//   //   } catch (e) {
//   //     print("Error sending notification: $e");
//   //   }
//   // }

//   String generateCollectionID(int length) {
//     const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
//     Random random = Random();
//     return List.generate(length, (index) => chars[random.nextInt(chars.length)])
//         .join('');
//   }

//   Widget _buildProductTable() {
//     final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

//     return ListView.builder(
//       shrinkWrap: true,
//       itemCount: _orders.length,
//       itemBuilder: (context, index) {
//         var order = _orders[index];
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Order ID: ${order['orderID']}',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'Purchase Date: ${formatter.format(order['purchaseDate'])}',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Table(
//               border: TableBorder.all(color: Colors.black),
//               children: [
//                 const TableRow(
//                   decoration:
//                       BoxDecoration(color: Color.fromARGB(255, 155, 49, 49)),
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text(
//                         'Product ID',
//                         style: TextStyle(
//                           fontWeight: FontWeight.normal,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text(
//                         'Product Name',
//                         style: TextStyle(
//                           fontWeight: FontWeight.normal,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text(
//                         'Quantity',
//                         style: TextStyle(
//                           fontWeight: FontWeight.normal,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 for (var product in order['orders'])
//                   TableRow(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(product['productID'] ?? ''),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(product['productName'] ?? ''),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(product['quantity'].toString()),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//             const SizedBox(height: 20), // Space between different orders
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     //final String collectionID = generateCollectionID(12);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Third Party Product Collection'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 16),
//             if (!_isAssigned)
//               Container(
//                 color: const Color.fromARGB(255, 225, 110, 85),
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const Text(
//                           'IR ID: ',
//                           style: TextStyle(
//                             color: Colors.white,
//                             height: 2.5,
//                           ),
//                         ),
//                         Text(
//                           authorizerIRID,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             height: 2.5,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Text(
//                       'List of Products: ',
//                       style: TextStyle(
//                         color: Colors.white,
//                         height: 2.5,
//                       ),
//                     ),
//                     _buildProductTable(),
//                   ],
//                 ),
//               ),
//             const SizedBox(height: 35),
//             if (!_isAssigned)
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(
//                     width: 190, // Set a fixed width for the label text
//                     child: Text(
//                       'Enter Collector IR ID:',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: SizedBox(
//                       height: 35, // Set the desired height
//                       child: TextField(
//                         controller: _collectorIrIdController,
//                         decoration: const InputDecoration(
//                           labelText: 'Enter IR ID',
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(
//                               vertical: 10.0), // Adjust padding for height
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             const SizedBox(height: 25),
//             const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Collector\'s Information',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (_isLoading) const CircularProgressIndicator(),
//             if (!_isLoading && _errorMessage.isNotEmpty)
//               Text(
//                 'Collector Name: $_errorMessage',
//                 style: const TextStyle(color: Colors.red),
//               ),
//             if (!_isLoading && _errorMessage.isEmpty)
//               Text(
//                 'Collector Name: $_collectorName',
//                 style: const TextStyle(color: Colors.black),
//               ),
//             if (!_isLoading && _errorMessage.isEmpty)
//               Text(
//                 'Collector IR ID: $_collectorIRID',
//                 style: const TextStyle(color: Colors.black),
//               ),
//             const SizedBox(height: 35),
//             if (!_isAssigned)
//               Center(
//                 child: ElevatedButton(
//                   onPressed: _errorMessage.isNotEmpty
//                       ? null
//                       : () async {
//                           if (_collectorName.isNotEmpty &&
//                               _collectorIRID.isNotEmpty) {
//                             try {
//                               //// Generate a unique collection ID using the current timestamp and authorizerIRID
//                               //String collectionID = DateTime.now().millisecondsSinceEpoch.toString() + '_${Get.find<AuthController>().authorizerIRID.value}';
//                               String collectionID = generateCollectionID(12);
//                               // Call the submitAuth function
//                               await submitAuth(
//                                   collectionID: collectionID,
//                                   collectorName: _collectorName,
//                                   collectorIRID: _collectorIRID,
//                                   authorizerName: _authorizerName,
//                                   authorizerIRID: authorizerIRID,
//                                   orders: _orders,
//                                   authStatus: 'Pending',
//                                   orderStatus: 'Uncollected',
//                                   orderReceived: 'No');
//                               //Refresh the list of orders
//                               await _fetchOrderData(authorizerIRID);

//                               String message =
//                                   "You have been assigned a new collection task";

//                               // await sendNotificationToCollector(
//                               //   _collectorIRID,
//                               //   message,
//                               //   _authorizerName,
//                               // );

//                               await _saveNotification(
//                                   _collectorIRID, _authorizerName);
//                               // Mark as assigned and clear order details
//                               setState(() {
//                                 _isAssigned = true;
//                                 _orders = [];
//                                 _orderID = '';
//                                 _purchaseDate = null;
//                                 _collectorIrIdController.clear();
//                               });
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       const SubmitSuccessScreen(),
//                                 ),
//                               ).then((_) {
//                                 Navigator.pop(
//                                     context); //pops the ThirdPartyDetailsScreen
//                               });
//                             } catch (e) {
//                               setState(() {
//                                 _errorMessage = 'Failed to submit order: $e';
//                               });
//                             }
//                           } else {
//                             setState(() {
//                               _errorMessage =
//                                   'Please enter a valid IR ID and ensure collector details are fetched.';
//                             });
//                           }
//                         },
//                   child: const Text(
//                     'CONFIRM',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 17,
//                       height: 1.5,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//fcm_third_party.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:vcon_3rdparty_auth/screens/submit_success.dart';
import 'package:vcon_3rdparty_auth/submit_auth.dart';
import 'package:vcon_3rdparty_auth/auth_controller.dart';

class ThirdPartyDetailsScreen extends StatefulWidget {
  const ThirdPartyDetailsScreen({super.key});

  @override
  State<ThirdPartyDetailsScreen> createState() =>
      _ThirdPartyDetailsScreenState();
}

class _ThirdPartyDetailsScreenState extends State<ThirdPartyDetailsScreen> {
  //final TextEditingController _irIdController = TextEditingController();
  final TextEditingController _collectorIrIdController =
      TextEditingController();
  String _collectorName = '';
  String _collectorIRID = '';
  String _authorizerName = '';
  //String _authorizerIRID = '';
  String _orderID = '';
  String? _selectedOrderID;
  List<String> _orderIDs = [];
  DateTime? _purchaseDate;
  List<Map<String, dynamic>> _orders = [];
  String _errorMessage = '';
  bool _isLoading = false;
  bool _isAssigned = false;

  // Create logger instance
  final Logger logger = Logger();

  //varaible to store authorizerIRID
  late String authorizerIRID;

  //final Uuid _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _collectorIrIdController.addListener(_onCollectorIDChanged);
    authorizerIRID = Get.find<AuthController>().authorizerIRID.value;
    _fetchOrderData(authorizerIRID);
    saveUserFCMToken(); // Call this instead of initializeFCMAndSaveToken
  }

  @override
  void dispose() {
    _collectorIrIdController.removeListener(_onCollectorIDChanged);
    _collectorIrIdController.dispose();
    super.dispose();
  }

  void _onCollectorIDChanged() {
    var collectorID = _collectorIrIdController.text.trim();
    if (collectorID.isNotEmpty) {
      _validateAndFetchCollector(collectorID);
    } else {
      setState(() {
        _collectorName = '';
        _collectorIRID = '';
        _errorMessage = '';
      });
    }
  }

  Future<void> _fetchOrderData(String userIRID) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      QuerySnapshot orderQuerySnapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where('irID', isEqualTo: userIRID.trim())
          .where('assignStatus', isEqualTo: 'Unassigned')
          .get();

      if (orderQuerySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> allOrders = [];

        for (var orderDocument in orderQuerySnapshot.docs) {
          var orderData = orderDocument.data() as Map<String, dynamic>;

          String orderID = orderData['orderID'] ?? '';
          DateTime purchaseDate =
              (orderData['purchaseDate'] as Timestamp).toDate();

          List<Map<String, dynamic>> orders = [];
          orderData['orders'].forEach((key, value) {
            orders.add({
              'productID': value['productID'] ?? '',
              'productName': value['productName'] ?? '',
              'quantity': value['quantity'] ?? 0,
            });
          });

          allOrders.add({
            'orderID': orderID,
            'purchaseDate': purchaseDate,
            'orders': orders,
          });
        }

        setState(() {
          _orders = allOrders;
          _authorizerName = orderQuerySnapshot.docs.first['irName'] ?? '';
          _orderID = orderQuerySnapshot.docs.first['orderID'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _orders = [];
          _errorMessage = 'No purchases found for this IRID.';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _orders = [];
        _errorMessage = 'Error fetching data: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _validateAndFetchCollector(String collectorID) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (collectorID.trim() == authorizerIRID) {
        setState(() {
          _collectorName = '';
          _collectorIRID = '';
          _errorMessage = 'You cannot assign yourself as a collector.';
          _isLoading = false;
        });
        return;
      }

      QuerySnapshot irQuerySnapshot = await FirebaseFirestore.instance
          .collection('IR')
          .where('irID', isEqualTo: collectorID.trim())
          .get();

      if (irQuerySnapshot.docs.isNotEmpty) {
        var irDocument = irQuerySnapshot.docs.first;
        var irData = irDocument.data() as Map<String, dynamic>;

        String irName = irData['irName'] ?? '';

        setState(() {
          _collectorName =
              irName.isEmpty ? 'Collector name not available' : irName;
          _collectorIRID = collectorID;
          _errorMessage = '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _collectorName = '';
          _collectorIRID = '';
          _errorMessage = 'No user found with IRID: $collectorID';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _collectorName = '';
        _collectorIRID = '';
        _errorMessage = 'Error fetching collector: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> saveUserFCMToken() async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await saveFCMToken(authorizerIRID, fcmToken);
        print(
            'FCM Token saved successfully for authorizerIRID: $authorizerIRID');
      } else {
        print('Error: FCM Token is null');
      }
    } catch (e) {
      print('Error saving FCM Token: $e');
    }
  }

  Future<void> saveFCMToken(String userIRID, String fcmToken) async {
    try {
      // Generate the current timestamp
      Timestamp currentTime = Timestamp.now();

      // Save the FCM token along with irID and time into the fcmTokens collection
      await FirebaseFirestore.instance.collection('fcmTokens').add({
        'irID': userIRID,
        'fcmToken': fcmToken,
        'time': currentTime,
      });

      print('FCM Token saved successfully for authorizerIRID: $userIRID');
    } catch (e) {
      print('Error saving FCM Token: $e');
    }
  }

  // Function to initialize FCM and save the token
  void initializeFCMAndSaveToken() async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        print('FCM Token: $fcmToken');
        await saveFCMToken(authorizerIRID, fcmToken);
      } else {
        print('Error: FCM Token is null');
      }
    } catch (e) {
      print('Error fetching FCM Token: $e');
    }
  }

  Future<void> _saveNotification(String recipientIRID, String authorizerName,
      String collectorName, String type) async {
    try {
      String title, body;
      Map<String, dynamic> notificationData = {
        'type': type,
        'title': '',
        'body': '',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      if (type == 'collect_products') {
        title = 'New Collection Task Assigned';
        body =
            'You have been assigned a new collection task by $authorizerName.';
        notificationData['collectorIRID'] = recipientIRID;
        notificationData['irID'] = authorizerIRID;
        notificationData['type'] = 'collect_products';
      } else if (type == 'my_products') {
        title = 'Collection Task Assigned';
        body = 'You have assigned a collection task to $collectorName.';
        notificationData['irID'] = recipientIRID;
        notificationData['collectorIRID'] = _collectorIRID;
        notificationData['type'] = 'my_products';
      } else {
        title = 'Notification';
        body = 'You have a new notification.';
        notificationData['recipientIRID'] = recipientIRID;
      }

      notificationData['title'] = title;
      notificationData['body'] = body;

      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('notifications')
          .add(notificationData);

      print('Notification saved successfully. Document ID: ${docRef.id}');
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  Future<void> testFcmTokenRetrieval(String collectorIRID) async {
    try {
      DocumentSnapshot collectorDoc = await FirebaseFirestore.instance
          .collection('IR')
          .doc(collectorIRID)
          .get();

      if (!collectorDoc.exists) {
        print('Error: Collector document does not exist');
        return;
      }

      String? fcmToken = collectorDoc.get('fcmToken');
      if (fcmToken == null || fcmToken.isEmpty) {
        print('Error: FCM token is not available for this collector');
        return;
      }

      print('FCM token for $collectorIRID: $fcmToken');
    } catch (e) {
      print('Error retrieving FCM token: $e');
    }
  }

  String generateCollectionID(int length) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join('');
  }

  Widget _buildProductTable() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        var order = _orders[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 163, 138, 236), Color.fromARGB(255, 166, 181, 250)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ID: ${order['orderID']}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Purchase Date: ${formatter.format(order['purchaseDate'])}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Table(
                  border: TableBorder.all(
                    color: const Color.fromARGB(255, 107, 14, 144)!,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color:const Color.fromARGB(255, 176, 16, 239)!,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      children: const[
                        TableCell(child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Product ID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        )),
                        TableCell(child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        )),
                        TableCell(child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        )),
                      ],
                    ),
                    for (var product in order['orders'])
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 209, 170, 232),
                        ),
                        children: [
                          TableCell(child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(product['productID'] ?? ''),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(product['productName'] ?? ''),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(product['quantity'].toString()),
                          )),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //final String collectionID = generateCollectionID(12);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Third Party Product Collection'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (!_isAssigned)
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color.fromARGB(255, 255, 128, 128), Color.fromARGB(255, 244, 149, 130)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IR ID: $authorizerIRID',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'List of Products:',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    _buildProductTable(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),
            if (!_isAssigned)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 190, // Set a fixed width for the label text
                    child: Text(
                      'Enter Collector IR ID:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 35, // Set the desired height
                      child: TextField(
                        controller: _collectorIrIdController,
                        decoration: const InputDecoration(
                          labelText: 'Enter IR ID',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0), // Adjust padding for height
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 25),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Collector\'s Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading && _errorMessage.isNotEmpty)
              Text(
                'Collector Name: $_errorMessage',
                style: const TextStyle(color: Colors.red),
              ),
            if (!_isLoading && _errorMessage.isEmpty)
              Text(
                'Collector Name: $_collectorName',
                style: const TextStyle(color: Colors.black),
              ),
            if (!_isLoading && _errorMessage.isEmpty)
              Text(
                'Collector IR ID: $_collectorIRID',
                style: const TextStyle(color: Colors.black),
              ),
            const SizedBox(height: 35),
            if (!_isAssigned)
              Center(
                child: ElevatedButton(
                  onPressed: _errorMessage.isNotEmpty
                      ? null
                      : () async {
                          if (_collectorName.isNotEmpty &&
                              _collectorIRID.isNotEmpty) {
                            try {
                              //// Generate a unique collection ID using the current timestamp and authorizerIRID
                              //String collectionID = DateTime.now().millisecondsSinceEpoch.toString() + '_${Get.find<AuthController>().authorizerIRID.value}';
                              String collectionID = generateCollectionID(12);
                              // Call the submitAuth function
                              await submitAuth(
                                  collectionID: collectionID,
                                  collectorName: _collectorName,
                                  collectorIRID: _collectorIRID,
                                  authorizerName: _authorizerName,
                                  authorizerIRID: authorizerIRID,
                                  orders: _orders,
                                  authStatus: 'Pending',
                                  orderStatus: 'Uncollected',
                                  orderReceived: 'No');
                              //Refresh the list of orders
                              await _fetchOrderData(authorizerIRID);

                              //String message =
                                 // "You have been assigned a new collection task";

                              // await sendNotificationToCollector(
                              //   _collectorIRID,
                              //   message,
                              //   _authorizerName,
                              // );
                              // await sendNotificationToCollector(
                              //   _collectorIRID,
                              //   message,
                              //   _authorizerName,
                              // );
                              await _saveNotification(
                                  _collectorIRID,
                                  _authorizerName,
                                  _collectorName,
                                  'collect_products');
                              await _saveNotification(
                                  authorizerIRID,
                                  _authorizerName,
                                  _collectorName,
                                  'my_products');
                              // Mark as assigned and clear order details
                              setState(() {
                                _isAssigned = true;
                                _orders = [];
                                _orderID = '';
                                _purchaseDate = null;
                                _collectorIrIdController.clear();
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SubmitSuccessScreen(),
                                ),
                              ).then((_) {
                                Navigator.pop(
                                    context); //pops the ThirdPartyDetailsScreen
                              });
                            } catch (e) {
                              setState(() {
                                _errorMessage = 'Failed to submit order: $e';
                              });
                            }
                          } else {
                            setState(() {
                              _errorMessage =
                                  'Please enter a valid IR ID and ensure collector details are fetched.';
                            });
                          }
                        },
                  child: const Text(
                    'CONFIRM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
