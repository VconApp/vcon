import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart'; 
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:vcon_3rdparty_auth/auth_controller.dart';
import 'package:vcon_3rdparty_auth/screens/collect_product.dart';
import 'package:vcon_3rdparty_auth/screens/agreed_collect_product.dart';

class CompletedCollectProductScreen extends StatefulWidget {
  final List<bool> isSelected;

  const CompletedCollectProductScreen({required this.isSelected, super.key});

  @override 
  CompletedCollectProductScreenState createState() => CompletedCollectProductScreenState();
}

class CompletedCollectProductScreenState extends State<CompletedCollectProductScreen> {
  List<bool> isSelected = [false, false, true];
  String _errorMessage = '';
  bool _isLoading = false;
  Map<String, dynamic> _orders = {};
  late String collectorIRID;
  final Logger logger = Logger(); 

  @override
  void initState() {
    super.initState();
    collectorIRID = Get.find<AuthController>().authorizerIRID.value;
    _completeCollection(collectorIRID);
  }

  @override 
  void dispose() {
    super.dispose();
  }

  Future<void> _completeCollection(String userIRID) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      QuerySnapshot displayQuerySnapshot = await FirebaseFirestore.instance
        .collection('ThirdPartyCollect')
        .where('collectorIRID', isEqualTo: userIRID.trim())
        .where('orderStatus', isEqualTo: 'Collected')
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
              if (!fetchedOrders[collectionID]['orders'].containsKey(orderID)) {
                fetchedOrders[collectionID]['orders'][orderID] = [];
              }
              
              if (order.containsKey('products') && order['products'] is List) {
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
              logger.d("Button $index pressed");
              if(index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CollectProductScreen(
                      isSelected: [true, false, false]),
                      ),
                );
              } else if (index == 1) {
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
                              .format(collection['authorizeTimestamp'].toDate());
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              color: const Color.fromARGB(255, 194, 230, 187),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Collection ID: ${collection['collectionID']}'),
                                    Text('Authorizer IRID: ${collection['authorizerIRID']}'),
                                    Text('Authorizer Name: ${collection['authorizerName']}'),
                                    Text('Authorize Date: $formattedDate'),
                                    const SizedBox(height: 8),
                                    ...collection['orders'].entries.map((entry) {
                                      String orderID = entry.key;
                                      List<dynamic> products = entry.value;
                                      return Card(
                                        color:  const Color.fromARGB(226, 128, 209, 151),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.8,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Order ID: $orderID'),
                                                const SizedBox(height: 8),
                                                ...products.map((product) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(left: 16.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text('Product ID: ${product['productID']}'),
                                                        Text('Product Name: ${product['productName']}'),
                                                        Text('Quantity: ${product['quantity']}'),
                                                        const SizedBox(height: 8),
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