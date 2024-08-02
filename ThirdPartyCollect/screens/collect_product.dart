//collect_product.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:vcon_3rdparty_auth/auth_controller.dart';
import 'package:vcon_3rdparty_auth/screens/completed_collect_product.dart';
import 'package:vcon_3rdparty_auth/screens/agreed_collect_product.dart';

class CollectProductScreen extends StatefulWidget {
  final List<bool> isSelected;

  const CollectProductScreen({required this.isSelected, super.key});

  @override
  CollectProductScreenState createState() => CollectProductScreenState();
}

class CollectProductScreenState extends State<CollectProductScreen> {
  List<bool> isSelected = [true, false, false];
  String _errorMessage = '';
  bool _isLoading = false;
  Map<String, dynamic> _orders = {};
  late String collectorIRID;

  @override
  void initState() {
    super.initState();
    collectorIRID = Get.find<AuthController>().authorizerIRID.value;
    _fetchCollectRequest(collectorIRID);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchCollectRequest(String userIRID) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      QuerySnapshot displayQuerySnapshot = await FirebaseFirestore.instance
          .collection('ThirdPartyCollect')
          .where('collectorIRID', isEqualTo: userIRID.trim())
          .where('authorizationStatus', isEqualTo: 'Pending')
          .get();

      if (displayQuerySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> fetchedOrders = {};

        for (var doc in displayQuerySnapshot.docs) {
          var displayData = doc.data() as Map<String, dynamic>;
          var orders = displayData['orders'];
          if (orders != null && orders is List) {
            String collectionID = displayData['collectionID'];
            if (!fetchedOrders.containsKey(collectionID)) {
              fetchedOrders[collectionID] = {
                'collectionID': collectionID,
                'authorizerIRID': displayData['purchaserIRID'],
                'authorizerName': displayData['purchaserName'],
                'authorizeTimestamp': displayData['authorizeTimestamp'],
                'orders': {}
              };
            }

            for (var order in orders) {
              if (order is Map<String, dynamic>) {
                String orderID = order['orderID'];
                if (!fetchedOrders[collectionID]['orders']
                    .containsKey(orderID)) {
                  fetchedOrders[collectionID]['orders'][orderID] = [];
                }

                if (order.containsKey('products') &&
                    order['products'] is List) {
                  for (var product in order['products']) {
                    fetchedOrders[collectionID]['orders'][orderID].add({
                      'productID': product['productID'],
                      'productName': product['productName'],
                      'quantity': product['quantity'],
                    });
                  }
                } else if (order.containsKey('productID')) {
                  fetchedOrders[collectionID]['orders'][orderID].add({
                    'productID': order['productID'],
                    'productName': order['productName'],
                    'quantity': order['quantity'],
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

  Future<void> _sendNotificationToAuthorizer(String collectionID) async {
    try {
      print('Sending notification to authorizer for collectionID: $collectionID');
      QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('ThirdPartyCollect')
        .where('collectionID', isEqualTo: collectionID)
        .limit(1)
        .get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        String authorizerIRID = data['purchaserIRID'];
        //String authorizerName = data['purchaserName'];
        String collectorIRID = data['collectorIRID'];

        // Fetch collector's name from IR collection
        DocumentSnapshot collectorDoc = await FirebaseFirestore.instance
            .collection('IR')
            .doc(collectorIRID)
            .get();

        String collectorName = 'A collector';
        if (collectorDoc.exists) {
          collectorName = (collectorDoc.data() as Map<String, dynamic>)['irName'] ?? 'A collector';
        }

        await FirebaseFirestore.instance.collection('notifications').add({
          'irID': authorizerIRID,
          'collectorIRID': collectorIRID,
          'type': 'my_products',
          'title': 'Collection Help',
          'body': '$collectorName is helping you to collect your product',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });

        print('Notification sent to authorizer successfully');
      } else {
        print('ThirdPartyCollect document not found for ID: $collectionID');
      }
    } catch (e) {
      print('Error sending notification to authorizer: $e');
    }
  }

  Future<void> _sendNotificationToCollector(String collectionID) async {
    try {
      print('Sending notification to collector for collectionID: $collectionID');
      QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('ThirdPartyCollect')
        .where('collectionID', isEqualTo: collectionID)
        .limit(1)
        .get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        String authorizerName = data['purchaserName'];
        String collectorIRID = data['collectorIRID'];

        await FirebaseFirestore.instance.collection('notifications').add({
          'collectorIRID': collectorIRID,
          'irID': data['purchaserIRID'],
          'type': 'collect_products',
          'title': 'Collection Agreement',
          'body': 'You have agreed to help $authorizerName collect their product',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });

        print('Notification sent to collector successfully');
      } else {
        print('ThirdPartyCollect document not found for ID: $collectionID');
      }
    } catch (e) {
      print('Error sending notification to collector: $e');
    }
  }

  Future<void> _helpToCollect(String collectionID) async {
    // Show confirmation dialog
    bool confirmCollection = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Collection'),
          content:
              const Text('Are you sure you want to help collect this product?'),
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
    if (confirmCollection == true) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        print('Attempting to find document with collectionID: $collectionID');
        // Query the document with the matching collectionID and authorizationStatus
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('ThirdPartyCollect')
            .where('collectorIRID', isEqualTo: collectorIRID)
            .where('authorizationStatus', isEqualTo: 'Pending')
            .where('collectionID', isEqualTo: collectionID)
            .get();

            print('Query returned ${snapshot.docs.length} documents');

        if (snapshot.docs.isNotEmpty) {
          print('Found matching document. Updating status...');
          // Update the document
          await FirebaseFirestore.instance
              .collection('ThirdPartyCollect')
              .doc(snapshot.docs.first.id)
              .update({'authorizationStatus': 'Agree'});
              print('Document updated. Sending notifications...');

          // Send notification to the authorizer
          await _sendNotificationToAuthorizer(collectionID);

          // Send notification to the collector (current user)
          await _sendNotificationToCollector(collectionID);

          setState(() {
            _isLoading = false;
            //remove the collected item from the local state
            _orders.remove(collectionID);
          });

          //show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Collection successfully updated')),
          );
        } else {
        print('No matching document found for collectionID: $collectionID');
        setState(() {
          _errorMessage = 'No matching document found.';
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error in _helpToCollect: $error');
      setState(() {
        _errorMessage = 'Error updating order: $error';
        _isLoading = false;
      });
      }
    }
  }

  Future<void> _sendNotificationToAuthorizerForRejection(String collectionID) async {
  try {
    print('Sending rejection notification to authorizer for collectionID: $collectionID');
    QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('ThirdPartyCollect')
      .where('collectionID', isEqualTo: collectionID)
      .limit(1)
      .get();

    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs.first.data() as Map<String, dynamic>;
      String authorizerIRID = data['purchaserIRID'];
      String collectorIRID = data['collectorIRID'];

      // Fetch collector's name from IR collection
      DocumentSnapshot collectorDoc = await FirebaseFirestore.instance
          .collection('IR')
          .doc(collectorIRID)
          .get();

      String collectorName = 'A collector';
      if (collectorDoc.exists) {
        collectorName = (collectorDoc.data() as Map<String, dynamic>)['irName'] ?? 'A collector';
      }

      await FirebaseFirestore.instance.collection('notifications').add({
        'irID': authorizerIRID,
        'collectorIRID': collectorIRID,
        'type': 'my_products',
        'title': 'Collection Rejected',
        'body': '$collectorName has rejected to collect your product. Please choose another collector.',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      print('Rejection notification sent to authorizer successfully');
    } else {
      print('ThirdPartyCollect document not found for ID: $collectionID');
    }
  } catch (e) {
    print('Error sending rejection notification to authorizer: $e');
  }
}

Future<void> _sendNotificationToCollectorForRejection(String collectionID) async {
  try {
    print('Sending rejection notification to collector for collectionID: $collectionID');
    QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('ThirdPartyCollect')
      .where('collectionID', isEqualTo: collectionID)
      .limit(1)
      .get();

    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs.first.data() as Map<String, dynamic>;
      String authorizerName = data['purchaserName'];
      String collectorIRID = data['collectorIRID'];

      await FirebaseFirestore.instance.collection('notifications').add({
        'collectorIRID': collectorIRID,
        'irID': data['purchaserIRID'],
        'type': 'collect_products',
        'title': 'Collection Rejected',
        'body': 'You have rejected to collect products for $authorizerName',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      print('Rejection notification sent to collector successfully');
    } else {
      print('ThirdPartyCollect document not found for ID: $collectionID');
    }
  } catch (e) {
    print('Error sending rejection notification to collector: $e');
  }
}

Future<void> _rejectCollect(String collectionID, List<dynamic> orderIDs) async {
  // Show confirmation dialog
  bool confirmReject = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Reject'),
        content: const Text('Are you sure you want to reject collect this product?'),
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

  // If user confirmed, proceed with the rejection
  if (confirmReject == true) {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Delete document in ThirdPartyCollect
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ThirdPartyCollect')
          .where('collectionID', isEqualTo: collectionID)
          .get();

      if (snapshot.docs.isNotEmpty) {
          // Send notifications
        await _sendNotificationToAuthorizerForRejection(collectionID);
        await _sendNotificationToCollectorForRejection(collectionID);
        
        await FirebaseFirestore.instance
            .collection('ThirdPartyCollect')
            .doc(snapshot.docs.first.id)
            .delete();
      }

      // Update orders collection
      for (var orderID in orderIDs) {
        QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
            .collection('Orders')
            .where('orderID', isEqualTo: orderID.toString())
            .get();

        if (ordersSnapshot.docs.isNotEmpty) {
          for (var doc in ordersSnapshot.docs) {
            await FirebaseFirestore.instance
                .collection('Orders')
                .doc(doc.id)
                .update({
              'assignStatus': 'Unassigned',
            });
          }
        }
      }

      // Remove rejected collection from local state
      setState(() {
        _orders.remove(collectionID);
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection rejected successfully')),
      );
    } catch (error) {
      setState(() {
        _isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting collection: $error')),
        );
      });
    }
  }
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
                  builder: (context) => const AgreedCollectProductsScreen(
                      isSelected: [false, true, false]),
                ),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const CompletedCollectProductScreen(
                      isSelected: [false, false, true]),
                ),
              );
            }
          },
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Collects Product'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Agreed'),
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
            : _orders.isEmpty
                ? Center(child: Text(_errorMessage))
                : Expanded(
                    child: ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        String collectionID = _orders.keys.elementAt(index);
                        var collection = _orders[collectionID];
                        String formattedDate = DateFormat('yyyy-MM-dd')
                            .format(
                                collection['authorizeTimestamp'].toDate());
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: const Color.fromARGB(255, 233, 198, 198),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Collection ID: ${collection['collectionID']}'),
                                  Text(
                                      'Authorizer IRID: ${collection['authorizerIRID']}'),
                                  Text(
                                      'Authorizer Name: ${collection['authorizerName']}'),
                                  Text('Authorize Date: $formattedDate'),
                                  const SizedBox(height: 8),
                                  ...collection['orders']
                                      .entries
                                      .map((entry) {
                                    String orderID = entry.key;
                                    List<dynamic> products = entry.value;
                                    return Card(
                                      color: const Color(0xFFD18080),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Order ID: $orderID'),
                                              const SizedBox(height: 8),
                                              ...products.map((product) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Product ID: ${product['productID']}'),
                                                      Text(
                                                          'Product Name: ${product['productName']}'),
                                                      Text(
                                                          'Quantity: ${product['quantity']}'),
                                                      const SizedBox(
                                                          height: 8),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _helpToCollect(
                                              collection['collectionID']);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFB73E3E),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Help to collect'),
                                      ),
                                      
                                      ElevatedButton(
                                        onPressed: () {
                                          var orderIDs = collection['orders']
                                              .keys
                                              .toList();
                                          _rejectCollect(
                                              collection['collectionID'],
                                              orderIDs);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFB73E3E),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Reject'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    ),
  );
}
}
