//completed_my_product.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vcon_3rdparty_auth/auth_controller.dart';

import 'package:vcon_3rdparty_auth/screens/my_products.dart';
import 'package:vcon_3rdparty_auth/widgets/order_card_completed_my_product.dart';

class CompletedMyProductsScreen extends StatefulWidget {
  final List<bool> isSelected;

  const CompletedMyProductsScreen({required this.isSelected, super.key});

  @override
  _CompletedMyProductsScreenState createState() => _CompletedMyProductsScreenState();
}

class _CompletedMyProductsScreenState extends State<CompletedMyProductsScreen> {
  late List<bool> isSelected = [false, true];
  late String authorizerIRID;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    isSelected = List.from(widget.isSelected);
    authorizerIRID = Get.find<AuthController>().authorizerIRID.value; 
    //_fetchOrderDetails(authorizerIRID);
    _fetchCompletedOrders(authorizerIRID);
  }

  Future<void> _fetchCompletedOrders(String userIRID) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      QuerySnapshot displayQuerySnapshot = await FirebaseFirestore.instance
          .collection('ThirdPartyCollect')
          .where('purchaserIRID', isEqualTo: userIRID.trim())
          .where('orderReceived', isEqualTo: 'Yes')
          .get();

      print("Number of documents: ${displayQuerySnapshot.docs.length}");

      if (displayQuerySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> fetchedOrders = [];

              for (var doc in displayQuerySnapshot.docs) {
        var displayData = doc.data() as Map<String, dynamic>;
        var orders = displayData['orders'];
        if (orders != null && orders is List) {
          for (var order in orders) {
            if (order is Map<String, dynamic>) {
              if (order.containsKey('products') && order['products'] is List) {
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

        print("Fetched orders: $fetchedOrders");

        setState(() {
          _orders = fetchedOrders;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No products have been collected.';
          _isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching data: $error");
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
              setState(() {
                isSelected = List.generate(isSelected.length, (i) => i == index);
              });
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyProductsScreen(isSelected: [true, false]),
                  ),
                );
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompletedMyProductsScreen(isSelected: [false, true]),
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
                                      child: OrderCardCompletedMyProducts(
                                        collectionID: order['collectionID'] ?? '',
                                        collectorIRID: order['collectorIRID'] ?? '',
                                        collectorName: order['collectorName'] ?? '',
                                        orderId: order['orderId'] ?? '',
                                        products: (order['products']
                                                    as List<dynamic>?)
                                                ?.cast<
                                                    Map<String, dynamic>>() ??
                                            [],
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
          };
        }
        groupedCollectionMap[collectionID]!['products']!
            .add(Map<String, dynamic>.from(order));
      }
    }

    return groupedCollectionMap.values.toList();
  }

}

