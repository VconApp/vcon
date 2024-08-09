// //one signal
//change_collector.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vcon_3rdparty_auth/auth_controller.dart';
import 'package:vcon_3rdparty_auth/onesignal_service.dart';

class ChangeCollectorScreen extends StatefulWidget {
  final String collectionID;
  final String collectorIRID;
  final String collectorName;
  final Timestamp authorizeTimestamp;
  final String orderStatus;
  final VoidCallback onUpdate;

  const ChangeCollectorScreen({
    required this.collectionID,
    required this.collectorIRID,
    required this.collectorName,
    required this.authorizeTimestamp,
    required this.orderStatus,
    required this.onUpdate,
    super.key
  });

  @override
  _ChangeCollectorScreen createState() => _ChangeCollectorScreen();
}

class _ChangeCollectorScreen extends State<ChangeCollectorScreen> {
  final TextEditingController _collectorIrIdController = TextEditingController();
  late String authorizerIRID;
  String _newCollectorName = '';
  String _newCollectorIRID = '';
  DateTime? _authTimestamp;
  bool _isLoading = false;
  String _errorMessage = '';
  Duration _remainingTime = const Duration(hours: 24);
  late Timer _timer;
  String _orderStatus = '';

  @override
  void initState() {
    super.initState();
    authorizerIRID = Get.find<AuthController>().authorizerIRID.value;
    _collectorIrIdController.addListener(_onCollectorIDChanged);
    //_fetchAuthTimestamp(widget.orderId);
    _setAuthTimestamp(widget.authorizeTimestamp);
    _startTimer();
    _fetchOrderStatus();
    _orderStatus = widget.orderStatus;
  }

  void _setAuthTimestamp(Timestamp timestamp) {
    setState(() {
      _authTimestamp = timestamp.toDate();
      _remainingTime = _calculateRemainingTime(_authTimestamp!);
    });
  }

  @override
  void dispose() {
    _collectorIrIdController.removeListener(_onCollectorIDChanged);
    _collectorIrIdController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _onCollectorIDChanged() {
    var collectorID = _collectorIrIdController.text.trim();
    if (collectorID.isNotEmpty) {
      _fetchCollectorInfo(
          _newCollectorIRID, widget.collectorIRID, widget.collectorName);
    } else {
      _newCollectorIRID = '';
      _newCollectorName = '';
      _errorMessage = '';
    }
  }

  Future<void> _fetchCollectorInfo(String newCollectorIRID,
      String collectorIRID, String collectorName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      String newCollectorIRID = _collectorIrIdController.text.trim();
      if (newCollectorIRID == authorizerIRID ||
          newCollectorIRID == collectorIRID) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'You cannot assign yourself nor the same collector.';
        });
        return;
      }

      QuerySnapshot newCollectorQuerySnapshot = await FirebaseFirestore.instance
          .collection('IR')
          .where('irID', isEqualTo: newCollectorIRID)
          .get();

      if (newCollectorQuerySnapshot.docs.isNotEmpty) {
        var newCollectorDocument = newCollectorQuerySnapshot.docs.first;
        var newCollectorData =
            newCollectorDocument.data() as Map<String, dynamic>;

        String newCollectorName = newCollectorData['irName'] ?? '';

        setState(() {
          _newCollectorName = newCollectorName.isEmpty
              ? 'Collector name not available'
              : newCollectorName;
          _newCollectorIRID = newCollectorIRID;
          _isLoading = false;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _newCollectorName = '';
          _newCollectorIRID = '';
          _errorMessage = 'No user found with IRID: $newCollectorIRID';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error changing collector: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchOrderStatus() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('ThirdPartyCollect')
          .doc(widget.collectionID)
          //.where('collectionID', isEqualTo: collectionID)
          .get();

      if (documentSnapshot.exists) {
        setState(() {
          _orderStatus = documentSnapshot['orderStatus'] ?? '';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching order status: $error';
      });
    }
  }

  void _simulateNotificationReceived(String recipientIRID, String title, String message) {
  print("Debug: Notification received by $recipientIRID");
  print("Debug: Title: $title");
  print("Debug: Message: $message");
}

  Future<void> _updateCollector(String collectionID, String newCollectorIRID,
    String newCollectorName) async {
  if (newCollectorIRID.isEmpty || newCollectorName.isEmpty) {
    setState(() {
      _errorMessage = 'Please fetch collector information before submitting.';
    });
    return;
  }

  if (_orderStatus == 'Collected') {
    _showCollectedStatusAlert();
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    print(
        "Updating collector for collectionID: $collectionID to newCollectorIRID: $newCollectorIRID with newCollectorName: $newCollectorName");

    // Query the document with the matching collectionID
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('ThirdPartyCollect')
        .where('collectionID', isEqualTo: collectionID)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

      // Get the old collector information
      String oldCollectorIRID = documentSnapshot['collectorIRID'];
      String oldCollectorName = documentSnapshot['collectorName'];

      // Update new collector details
      await documentSnapshot.reference.update({
        'collectorIRID': newCollectorIRID,
        'collectorName': newCollectorName,
      });

      // Create OneSignal user for the new collector
      await OneSignalService.createOneSignalUser(newCollectorIRID);

      // Send notifications
      await _sendChangeCollectorNotifications(
        collectionID,
        oldCollectorIRID,
        oldCollectorName,
        newCollectorIRID,
        newCollectorName
      );

      print("Debug: Notifications sent successfully");

      setState(() {
        _isLoading = false;
        _errorMessage = 'Collector changed successfully.';
      });

      // Call the onUpdate callback
      widget.onUpdate();
      // Debug: Simulate receiving notifications
      _simulateNotificationReceived(authorizerIRID, "Collector Changed", "You have changed the collector for collection $collectionID from $oldCollectorName to $newCollectorName");
      _simulateNotificationReceived(newCollectorIRID, "New Collection Assigned", "You have been assigned as the collector for collection $collectionID");
      _simulateNotificationReceived(oldCollectorIRID, "Collection Assignment Removed", "You are no longer the collector for collection $collectionID");
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'CollectionID: $collectionID is unavailable.';
      });
    }
  } catch (error) {
    setState(() {
      _isLoading = false;
      _errorMessage = 'Error changing collector: $error';
    });
  }

  // Introduce a delay before popping the screen
  await Future.delayed(const Duration(seconds: 2));

  // Pop the current screen to go back to MyProductsScreen
  Navigator.pop(context);
}

Future<void> _sendOneSignalNotification(String externalUserId, String title, String message, String notificationType) async {
  const String oneSignalAppId = '40418a90-aa30-451e-a850-8ff601bd7930';
  const String restApiKey = 'NjczOWUxZTctMTUyZS00NDgwLTk4MDAtODcyNjM0ZTFhYTU3';

  try {
    final response = await http.post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $restApiKey',
      },
      body: json.encode({
        'app_id': oneSignalAppId,
        'include_external_user_ids': [externalUserId],
        'contents': {'en': message},
        'headings': {'en': title},
        'data': {'type': notificationType},
      }),
    );

    if (response.statusCode == 200) {
      print('OneSignal notification sent successfully');
    } else {
      print('Failed to send OneSignal notification. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error sending OneSignal notification: $e');
  }
}
Future<void> _sendChangeCollectorNotifications(
    String collectionID,
    String oldCollectorIRID,
    String oldCollectorName,
    String newCollectorIRID,
    String newCollectorName) async {
  try {
    // Get the current user's IRID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('IR')
        .where('email', isEqualTo: user.email)
        .get()
        .then((snapshot) => snapshot.docs.first);

    String userIRID = userDoc.get('irID');

    // Send notification to the user (My Products)
    await FirebaseFirestore.instance.collection('notifications').add({
      'irID': userIRID,
      'type': 'my_products',
      'title': 'Collector Changed',
      'body': 'You have changed the collector for collection $collectionID from $oldCollectorName to $newCollectorName',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Send notification to the new collector (Collect Products)
    await FirebaseFirestore.instance.collection('notifications').add({
      'collectorIRID': newCollectorIRID,
      'type': 'collect_products',
      'title': 'New Collection Assigned',
      'body': 'You have been assigned as the collector for collection $collectionID',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Send notification to the old collector (Collect Products)
    await FirebaseFirestore.instance.collection('notifications').add({
      'collectorIRID': oldCollectorIRID,
      'type': 'collect_products',
      'title': 'Collection Assignment Removed',
      'body': 'You are no longer the collector for collection $collectionID',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Send notification to the user (My Products)
      await _sendOneSignalNotification(
        authorizerIRID,
        'Collector Changed',
        'You have changed the collector for collection $collectionID from $oldCollectorName to $newCollectorName',
        'my_products'
      );

      // Send notification to the new collector (Collect Products)
      await _sendOneSignalNotification(
        newCollectorIRID,
        'New Collection Assigned',
        'You have been assigned as the collector for collection $collectionID',
        'collect_products'
      );

      // Send notification to the old collector (Collect Products)
      await _sendOneSignalNotification(
        oldCollectorIRID,
        'Collection Assignment Removed',
        'You are no longer the collector for collection $collectionID',
        'collect_products'
      );

    // Optionally, you can also send push notifications here if you have FCM set up
  } catch (error) {
    print('Error sending notifications: $error');
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

  Duration _calculateRemainingTime(DateTime authTimestamp) {
    DateTime now = DateTime.now();
    DateTime oneDayAfter = authTimestamp.add(const Duration(days: 1));
    Duration remainingTime = oneDayAfter.difference(now);
    return remainingTime.isNegative ? Duration.zero : remainingTime;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 600,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_remainingTime.inSeconds > 0)
                    Text(
                      'Remaining time to change collector: ${_remainingTime.inHours}:${_remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )
                  else
                    const Text(
                      'Cannot change collector, 24 hours have passed.',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  const SizedBox(height: 25),
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading) const CircularProgressIndicator(),
                  if (!_isLoading && _errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  if (!_isLoading && _errorMessage.isEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Collector Name: $_newCollectorName',
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Collector IR ID: $_newCollectorIRID',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  const SizedBox(height: 35),
                  Center(
                    child: ElevatedButton(
                      onPressed: _remainingTime.inSeconds > 0
                          ? () => _updateCollector(widget.collectionID,
                              _newCollectorIRID, _newCollectorName)
                          : null,
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//change_collector.dart
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:async';

// import 'package:vcon_3rdparty_auth/auth_controller.dart';
// import 'package:vcon_3rdparty_auth/notification_service.dart';

// class ChangeCollectorScreen extends StatefulWidget {
//   final String collectionID;
//   final String collectorIRID;
//   final String collectorName;
//   final Timestamp authorizeTimestamp;
//   final String orderStatus;
//   final VoidCallback onUpdate;

//   const ChangeCollectorScreen(
//       {required this.collectionID,
//       required this.collectorIRID,
//       required this.collectorName,
//       required this.authorizeTimestamp,
//       required this.orderStatus,
//       required this.onUpdate,
//       super.key});

//   @override
//   _ChangeCollectorScreen createState() => _ChangeCollectorScreen();
// }

// class _ChangeCollectorScreen extends State<ChangeCollectorScreen> {
//   final TextEditingController _collectorIrIdController =
//       TextEditingController();
//   late String authorizerIRID;
//   String _newCollectorName = '';
//   String _newCollectorIRID = '';
//   DateTime? _authTimestamp;
//   bool _isLoading = false;
//   String _errorMessage = '';
//   Duration _remainingTime = const Duration(hours: 24);
//   late Timer _timer;
//   String _orderStatus = '';

//   @override
//   void initState() {
//     super.initState();
//     authorizerIRID = Get.find<AuthController>().authorizerIRID.value;
//     _collectorIrIdController.addListener(_onCollectorIDChanged);
//     //_fetchAuthTimestamp(widget.orderId);
//     _setAuthTimestamp(widget.authorizeTimestamp);
//     _startTimer();
//     _fetchOrderStatus();
//     _orderStatus = widget.orderStatus;
//   }

//   void _setAuthTimestamp(Timestamp timestamp) {
//     setState(() {
//       _authTimestamp = timestamp.toDate();
//       _remainingTime = _calculateRemainingTime(_authTimestamp!);
//     });
//   }

//   @override
//   void dispose() {
//     _collectorIrIdController.removeListener(_onCollectorIDChanged);
//     _collectorIrIdController.dispose();
//     _timer.cancel();
//     super.dispose();
//   }

//   void _onCollectorIDChanged() {
//     var collectorID = _collectorIrIdController.text.trim();
//     if (collectorID.isNotEmpty) {
//       _fetchCollectorInfo(
//           _newCollectorIRID, widget.collectorIRID, widget.collectorName);
//     } else {
//       _newCollectorIRID = '';
//       _newCollectorName = '';
//       _errorMessage = '';
//     }
//   }

//   Future<void> _fetchCollectorInfo(String newCollectorIRID,
//       String collectorIRID, String collectorName) async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       String newCollectorIRID = _collectorIrIdController.text.trim();
//       if (newCollectorIRID == authorizerIRID ||
//           newCollectorIRID == collectorIRID) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = 'You cannot assign yourself nor the same collector.';
//         });
//         return;
//       }

//       QuerySnapshot newCollectorQuerySnapshot = await FirebaseFirestore.instance
//           .collection('IR')
//           .where('irID', isEqualTo: newCollectorIRID)
//           .get();

//       if (newCollectorQuerySnapshot.docs.isNotEmpty) {
//         var newCollectorDocument = newCollectorQuerySnapshot.docs.first;
//         var newCollectorData =
//             newCollectorDocument.data() as Map<String, dynamic>;

//         String newCollectorName = newCollectorData['irName'] ?? '';

//         setState(() {
//           _newCollectorName = newCollectorName.isEmpty
//               ? 'Collector name not available'
//               : newCollectorName;
//           _newCollectorIRID = newCollectorIRID;
//           _isLoading = false;
//           _errorMessage = '';
//         });
//       } else {
//         setState(() {
//           _newCollectorName = '';
//           _newCollectorIRID = '';
//           _errorMessage = 'No user found with IRID: $newCollectorIRID';
//           _isLoading = false;
//         });
//       }
//     } catch (error) {
//       setState(() {
//         _errorMessage = 'Error changing collector: $error';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchOrderStatus() async {
//     try {
//       DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
//           .collection('ThirdPartyCollect')
//           .doc(widget.collectionID)
//           //.where('collectionID', isEqualTo: collectionID)
//           .get();

//       if (documentSnapshot.exists) {
//         setState(() {
//           _orderStatus = documentSnapshot['orderStatus'] ?? '';
//         });
//       }
//     } catch (error) {
//       setState(() {
//         _errorMessage = 'Error fetching order status: $error';
//       });
//     }
//   }

//   Future<void> _updateCollector(String collectionID, String newCollectorIRID,
//       String newCollectorName) async {
//     if (newCollectorIRID.isEmpty || newCollectorName.isEmpty) {
//       setState(() {
//         _errorMessage = 'Please fetch collector information before submitting.';
//       });
//       return;
//     }

//     if (_orderStatus == 'Collected') {
//       _showCollectedStatusAlert();
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       print(
//           "Updating collector for collectionID: $collectionID to newCollectorIRID: $newCollectorIRID with newCollectorName: $newCollectorName");

//       // Query the document with the matching collectionID
//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection('ThirdPartyCollect')
//           .where('collectionID', isEqualTo: collectionID)
//           .limit(1)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

//         // Get the old collector information
//         String oldCollectorIRID = documentSnapshot['collectorIRID'];
//         String oldCollectorName = documentSnapshot['collectorName'];

//         // Update new collector details
//         await documentSnapshot.reference.update({
//           'collectorIRID': newCollectorIRID,
//           'collectorName': newCollectorName,
//         });

//         // Send notifications
//         await _sendChangeCollectorNotifications(collectionID, oldCollectorIRID,
//             oldCollectorName, newCollectorIRID, newCollectorName);

//         await NotificationService.display(RemoteMessage(
//           notification: RemoteNotification(
//             title: 'Collector Changed',
//             body:
//                 'The collector for collection $collectionID has been updated.',
//           ),
//         ));

//         setState(() {
//           _isLoading = false;
//           _errorMessage = 'Collector changed successfully.';
//         });

//         // Call the onUpdate callback
//         widget.onUpdate();
//       } else {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = 'CollectionID: $collectionID is unavailable.';
//         });
//       }
//     } catch (error) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Error changing collector: $error';
//       });
//     }

//     // Introduce a delay before popping the screen
//     await Future.delayed(const Duration(seconds: 2));

//     // Pop the current screen to go back to MyProductsScreen
//     Navigator.pop(context);
//   }

//   Future<void> _sendChangeCollectorNotifications(
//     String collectionID,
//     String oldCollectorIRID,
//     String oldCollectorName,
//     String newCollectorIRID,
//     String newCollectorName) async {
//   try {
//     // Get the current user's IRID
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     DocumentSnapshot userDoc = await FirebaseFirestore.instance
//         .collection('IR')
//         .where('email', isEqualTo: user.email)
//         .get()
//         .then((snapshot) => snapshot.docs.first);

//     String userIRID = userDoc.get('irID');

//     // Send notification to the user (My Products)
//     await FirebaseFirestore.instance.collection('notifications').add({
//       'irID': userIRID,
//       'type': 'my_products',
//       'title': 'Collector Changed',
//       'body':
//           'You have changed the collector for collection $collectionID from $oldCollectorName to $newCollectorName',
//       'timestamp': FieldValue.serverTimestamp(),
//       'isRead': false,
//     });

//     // Local notification for the user
//     await NotificationService.display(RemoteMessage(
//       notification: RemoteNotification(
//         title: 'Collector Changed',
//         body: 'You have changed the collector for collection $collectionID from $oldCollectorName to $newCollectorName',
//       ),
//       data: {
//         'route': 'my_products',
//       },
//     ));

//     // Send notification to the new collector (Collect Products)
//     await FirebaseFirestore.instance.collection('notifications').add({
//       'collectorIRID': newCollectorIRID,
//       'type': 'collect_products',
//       'title': 'New Collection Assigned',
//       'body':
//           'You have been assigned as the collector for collection $collectionID',
//       'timestamp': FieldValue.serverTimestamp(),
//       'isRead': false,
//     });

//     // Local notification for the new collector
//     await NotificationService.display(RemoteMessage(
//       notification: RemoteNotification(
//         title: 'New Collection Assigned',
//         body: 'You have been assigned as the collector for collection $collectionID',
//       ),
//       data: {
//         'route': 'collect_products',
//       },
//     ));

//     // Send notification to the old collector (Collect Products)
//     await FirebaseFirestore.instance.collection('notifications').add({
//       'collectorIRID': oldCollectorIRID,
//       'type': 'collect_products',
//       'title': 'Collection Assignment Removed',
//       'body': 'You are no longer the collector for collection $collectionID',
//       'timestamp': FieldValue.serverTimestamp(),
//       'isRead': false,
//     });

//     // Local notification for the old collector
//     await NotificationService.display(RemoteMessage(
//       notification: RemoteNotification(
//         title: 'Collection Assignment Removed',
//         body: 'You are no longer the collector for collection $collectionID',
//       ),
//       data: {
//         'route': 'collect_products',
//       },
//     ));

//     // Optionally, you can also send push notifications here if you have FCM set up
//   } catch (error) {
//     print('Error sending notifications: $error');
//   }
// }

//   void _showCollectedStatusAlert() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Cannot Change Collector'),
//           content: const Text('The order has already been collected.'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Duration _calculateRemainingTime(DateTime authTimestamp) {
//     DateTime now = DateTime.now();
//     DateTime oneDayAfter = authTimestamp.add(const Duration(days: 1));
//     Duration remainingTime = oneDayAfter.difference(now);
//     return remainingTime.isNegative ? Duration.zero : remainingTime;
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         if (_remainingTime.inSeconds > 0) {
//           _remainingTime = _remainingTime - const Duration(seconds: 1);
//         } else {
//           _timer.cancel();
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black.withOpacity(0.5),
//       body: Center(
//         child: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             Container(
//               width: 600,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFF9E3),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (_remainingTime.inSeconds > 0)
//                     Text(
//                       'Remaining time to change collector: ${_remainingTime.inHours}:${_remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0')}',
//                       style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black),
//                     )
//                   else
//                     const Text(
//                       'Cannot change collector, 24 hours have passed.',
//                       style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.red),
//                     ),
//                   const SizedBox(height: 25),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       const SizedBox(
//                         width: 190, // Set a fixed width for the label text
//                         child: Text(
//                           'Enter Collector IR ID:',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: SizedBox(
//                           height: 35, // Set the desired height
//                           child: TextField(
//                             controller: _collectorIrIdController,
//                             decoration: const InputDecoration(
//                               labelText: 'Enter IR ID',
//                               border: OutlineInputBorder(),
//                               contentPadding: EdgeInsets.symmetric(
//                                   vertical: 10.0), // Adjust padding for height
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 25),
//                   const Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Collector\'s Information',
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   if (_isLoading) const CircularProgressIndicator(),
//                   if (!_isLoading && _errorMessage.isNotEmpty)
//                     Text(
//                       _errorMessage,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   if (!_isLoading && _errorMessage.isEmpty)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Collector Name: $_newCollectorName',
//                           style: const TextStyle(color: Colors.black),
//                         ),
//                         Text(
//                           'Collector IR ID: $_newCollectorIRID',
//                           style: const TextStyle(color: Colors.black),
//                         ),
//                       ],
//                     ),
//                   const SizedBox(height: 35),
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: _remainingTime.inSeconds > 0
//                           ? () => _updateCollector(widget.collectionID,
//                               _newCollectorIRID, _newCollectorName)
//                           : null,
//                       child: const Text('Submit'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Positioned(
//               right: -10,
//               top: -10,
//               child: Container(
//                 decoration: const BoxDecoration(
//                   color: Colors.red,
//                   shape: BoxShape.circle,
//                 ),
//                 child: IconButton(
//                   icon: const Icon(Icons.close, color: Colors.white),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
