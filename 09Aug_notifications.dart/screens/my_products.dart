//my_products.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:vcon_3rdparty_auth/auth_controller.dart';
import 'package:vcon_3rdparty_auth/screens/completed_my_product.dart';
import 'package:vcon_3rdparty_auth/screens/change_collector.dart';
import 'package:vcon_3rdparty_auth/widgets/combined_order_card.dart';
import 'package:vcon_3rdparty_auth/onesignal_service.dart';

class MyProductsScreen extends StatefulWidget {
  final List<bool> isSelected;

  const MyProductsScreen({required this.isSelected, super.key});

  @override
  _MyProductsScreenState createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  late String authorizerIRID;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';
  List<bool> isSelected = [true, false];

  @override
  void initState() {
    super.initState();
    authorizerIRID = Get.find<AuthController>().authorizerIRID.value;
    _displayMyProductsList(authorizerIRID);
  }

  Future<void> _displayMyProductsList(String userIRID) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      QuerySnapshot displayQuerySnapshot = await FirebaseFirestore.instance
          .collection('ThirdPartyCollect')
          .where('purchaserIRID', isEqualTo: userIRID.trim())
          //.where('orderStatus', isEqualTo: 'Uncollected')
          .where('orderReceived', isEqualTo: 'No')
          .get();

      if (displayQuerySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> fetchedOrders = [];

        for (var doc in displayQuerySnapshot.docs) {
          var displayData = doc.data() as Map<String, dynamic>;
          var orders = displayData['orders'];
          if (orders != null && orders is List) {
            for (var order in orders) {
              if (order is Map<String, dynamic>) {
                if (order.containsKey('products') &&
                    order['products'] is List) {
                  for (var product in order['products']) {
                    fetchedOrders.add({
                      'orderID': order['orderID'],
                      'collectionID': displayData['collectionID'],
                      'collectorIRID': displayData['collectorIRID'],
                      'collectorName': displayData['collectorName'],
                      'productID': product['productID'],
                      'productName': product['productName'],
                      'quantity': product['quantity'],
                      'date': order['purchaseDate'],
                      'authorizeTimestamp': displayData['authorizeTimestamp'],
                      'status': displayData['orderStatus'],
                    });
                  }
                } else if (order.containsKey('productID')) {
                  fetchedOrders.add({
                    'orderID': displayData['orderID'],
                    'collectionID': displayData['collectionID'],
                    'collectorIRID': displayData['collectorIRID'],
                    'collectorName': displayData['collectorName'],
                    'productID': order['productID'],
                    'productName': order['productName'],
                    'quantity': order['quantity'],
                    'date': displayData['purchaseDate'],
                    'authorizeTimestamp': displayData['authorizeTimestamp'],
                    'status': displayData['orderStatus'],
                  });
                }
              }
            }
          }
        }

        setState(() {
          _orders = fetchedOrders;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No orders found.';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching orders: $error';
        _isLoading = false;
      });
    }
  }

  void _showCollectedStatusAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cannot Change Collector'),
          content: const Text(
              'The order has already been collected.'),
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

  void navigateToChangeCollectorScreen(String collectionID, String collectorIRID,
    String collectorName, Timestamp authorizeTimestamp, String orderStatus) {
    print("Attempting to navigate to ChangeCollectorScreen:");
    print("CollectionID: $collectionID");
    print("CollectorIRID: $collectorIRID");
    print("CollectorName: $collectorName");
    print("Order Status: $orderStatus");

    if (orderStatus == 'Collected') {
      print("Order status is Collected. Showing alert.");
      _showCollectedStatusAlert();
    } else {    
      print("Navigating to ChangeCollectorScreen");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeCollectorScreen(
            collectionID: collectionID,
            collectorIRID: collectorIRID,
            collectorName: collectorName,
            authorizeTimestamp: authorizeTimestamp,
            orderStatus: orderStatus,
            onUpdate: () {
              setState(() {
                _displayMyProductsList(authorizerIRID);
              });
            },
          ),
        ),
      );
    }
  }

  void onOrderReceived(String collectionID, List<String> orderIDs) {
    markOrderAsReceived(collectionID, orderIDs);
  }

  Future<void> _sendOrderReceivedNotifications(String collectionID, List<String> orderIDs) async {
    try {
      print("Starting _sendOrderReceivedNotifications for collectionID: $collectionID");
      
      // Get the current user's IRID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("Current user is null. Aborting notification send.");
        return;
      }
      
      print("Fetching user document for email: ${user.email}");
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('IR')
          .where('email', isEqualTo: user.email)
          .get();
      
      if (userSnapshot.docs.isEmpty) {
        print("No user document found for email: ${user.email}");
        return;
      }

      DocumentSnapshot userDoc = userSnapshot.docs.first;
      String userIRID = userDoc.get('irID');
      String userName = userDoc.get('irName') ?? 'User';
      print("User IRID fetched: $userIRID");

      // Send notification to the user (My Products)
      print("Sending 'My Products' notification to user");
      await FirebaseFirestore.instance.collection('notifications').add({
        'irID': userIRID,
        'type': 'my_products',
        'title': 'Order Received',
        'body': 'You have confirmed receipt of your order(s) for collection $collectionID. The order(s) have been marked as completed.',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      print("'My Products' notification sent successfully");

      await OneSignalService.sendOneSignalNotification(
        userIRID,
        'Order Received',
        'You have confirmed receipt of your order(s) for collection $collectionID.',
        'my_products'
      );

      // Query the ThirdPartyCollect collection
      print("Querying ThirdPartyCollect for collectionID: $collectionID");
      QuerySnapshot collectionQuery = await FirebaseFirestore.instance
          .collection('ThirdPartyCollect')
          .where('collectionID', isEqualTo: collectionID)
          .limit(1)
          .get();
      
      if (collectionQuery.docs.isEmpty) {
        print('Collection document not found for ID: $collectionID');
        return;
      }

      DocumentSnapshot collectionDoc = collectionQuery.docs.first;
      Map<String, dynamic> collectionData = collectionDoc.data() as Map<String, dynamic>;
      
      String collectorIRID = collectionData['collectorIRID'];
      print("Collector IRID fetched: $collectorIRID");

      if (collectorIRID == null || collectorIRID.isEmpty) {
        print('Collector IRID not found in the document');
        return;
      }

      // Send notification to the collector (Collect Products)
      print("Sending 'Collect Products' notification to collector");
      await FirebaseFirestore.instance.collection('notifications').add({
        'collectorIRID': collectorIRID,
        'type': 'collect_products',
        'title': 'Order Completed',
        'body': 'The order(s) you collected for collection $collectionID have been confirmed as received by the customer.',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      await OneSignalService.sendOneSignalNotification(
        collectorIRID,
        'Order Completed',
        'The order(s) you collected for collection $collectionID have been confirmed as received by $userName.',
        'collect_products'
      );

      print("'Collect Products' notification sent successfully");

    } catch (error) {
      print('Error in _sendOrderReceivedNotifications: $error');
    }
  }
  

  Future<void> markOrderAsReceived(String collectionID, List<String> orderIDs) async {
    // Show confirmation dialog
    bool confirmReceived = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Received'),
          content: const Text('Are you sure you receive the product?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    // If user confirmed, proceed with the collection
    if (confirmReceived == true) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        // Update in ThirdPartyCollect
        QuerySnapshot thirdPartyQuerySnapshot = await FirebaseFirestore.instance
          .collection('ThirdPartyCollect')
          .where('collectionID', isEqualTo: collectionID)
          .get();

        if (thirdPartyQuerySnapshot.docs.isNotEmpty) {
          await thirdPartyQuerySnapshot.docs.first.reference
              .update({'orderStatus': 'Received', 'orderReceived': 'Yes'});
          print("ThirdPartyCollect updated successfully.");
        } else {
          print("No matching document found in ThirdPartyCollect.");
        }

        // Update each order in Orders
        for (var orderID in orderIDs) {
          QuerySnapshot ordersQuerySnapshot = await FirebaseFirestore.instance
              .collection('Orders')
              .where('orderID', isEqualTo: orderID)
              .get();

          for (var doc in ordersQuerySnapshot.docs) {
            await doc.reference
                .update({'orderStatus': 'Received', 'orderReceived': 'Yes'});
          }
        }

        print("Collection marked as received in Firestore.");

        await _sendOrderReceivedNotifications(collectionID, orderIDs);

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Great! Your product(s) have been marked as received. You can find them in the "Completed" tab.'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'View Completed',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompletedMyProductsScreen(isSelected: [false, true]),
                  ),
                );
              },
            ),
          ),
        );

        await _displayMyProductsList(authorizerIRID);
      } catch (error) {
        setState(() {
          _errorMessage = 'Error updating order: $error';
          _isLoading = false;
        });
        print("Error marking collection as received: $error");
        rethrow;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Status'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ToggleButtons(
            isSelected: isSelected,
            onPressed: (int index) {
              setState(() {
                for (int i = 0; i < isSelected.length; i++) {
                  isSelected[i] = i == index;
                }
              });
              if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompletedMyProductsScreen(
                        isSelected: [false, true]),
                  ),
                );
              }
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('My Products'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Completed'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage))
                  : Expanded(
                      child: _orders.isEmpty
                          ? const Center(child: Text('No orders found'))
                          : ListView.builder(
                              itemCount: _groupedCollection().length,
                              itemBuilder: (context, index) {
                                var order = _groupedCollection()[index];
                                return Column(
                                  children: [
                                    Center(
                                      child: CombinedOrderCard(
                                        collectionID:
                                            order['collectionID'] ?? '',
                                        collectorIRID:
                                            order['collectorIRID'] ?? '',
                                        collectorName:
                                            order['collectorName'] ?? '',
                                        orderId: order['orderId'] ?? '',
                                        products: (order['products']
                                                    as List<dynamic>?)
                                                ?.cast<
                                                    Map<String, dynamic>>() ??
                                            [],
                                        onChangeCollector: () {
                                          navigateToChangeCollectorScreen(
                                            //order['orderID'] ?? '',
                                            order['collectionID'] ?? '',
                                            order['collectorIRID'] ?? '',
                                            order['collectorName'] ?? '',
                                            order['products']?[0]
                                                    ?['authorizeTimestamp'] ??
                                                Timestamp.now(),
                                            order['status'] ?? '',
                                          );
                                        },
                                        onOrderReceived:
                                            (collectionID, orderIDs) {
                                          markOrderAsReceived(
                                              collectionID, orderIDs);
                                        },
                                        isSelected: isSelected[0],
                                        orderStatus: order['status'] ?? '',
                                        navigateToChangeCollectorScreen:
                                            (String collectionID,
                                                String collectorIRID,
                                                String collectorName,
                                                Timestamp authorizeTimestamp) {
                                          print("Order status: ${order['status']}");
                                          navigateToChangeCollectorScreen(
                                            collectionID,
                                            collectorIRID,
                                            collectorName,
                                            authorizeTimestamp,
                                            order['status'] ?? '',
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _groupedCollection() {
    Map<String, Map<String, dynamic>> groupedCollectionMap = {};

    for (var order in _orders) {
      String collectionID = order['collectionID'] ?? '';
      String orderId = order['orderID'] ?? '';
      if (collectionID.isNotEmpty && orderId.isNotEmpty) {
        if (!groupedCollectionMap.containsKey(collectionID)) {
          groupedCollectionMap[collectionID] = {
            'collectorIRID': order['collectorIRID'] ?? '',
            'collectorName': order['collectorName'] ?? '',
            'collectionID': collectionID,
            'orderId': orderId,
            'products': <Map<String, dynamic>>[],
            'status': order['status'] ?? '', 
          };
        }
        groupedCollectionMap[collectionID]!['products']!
            .add(Map<String, dynamic>.from(order));
      }
    }

    return groupedCollectionMap.values.toList();
  }
}