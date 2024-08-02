// // //notification.dart
// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';

// // class NotificationScreen extends StatefulWidget {
// //   const NotificationScreen({Key? key}) : super(key: key);

// //   @override
// //   _NotificationScreenState createState() => _NotificationScreenState();
// // }

// // class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
// //   late TabController _tabController;
// //   final user = FirebaseAuth.instance.currentUser;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 2, vsync: this);

// //   }

// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Notifications'),
// //         bottom: TabBar(
// //           controller: _tabController,
// //           tabs: const [
// //             Tab(text: 'My Products'),
// //             Tab(text: 'Collect Products'),
// //           ],
// //         ),
// //       ),
// //       body: TabBarView(
// //         controller: _tabController,
// //         children: [
// //           NotificationList(type: 'my_products'),
// //           NotificationList(type: 'collect_products'),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class NotificationList extends StatelessWidget {
// //   final String type;

// //   const NotificationList({Key? key, required this.type}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     final user = FirebaseAuth.instance.currentUser;

// //     return StreamBuilder<QuerySnapshot>(
// //       stream: FirebaseFirestore.instance
// //           .collection('notifications')
// //           .where('userID', isEqualTo: user?.uid)
// //           .where('type', isEqualTo: type)
// //           .orderBy('timestamp', descending: true)
// //           .snapshots(),
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Center(child: CircularProgressIndicator());
// //         }

// //         if (snapshot.hasError) {
// //           return Center(child: Text('Error: ${snapshot.error}'));
// //         }

// //         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //           return const Center(child: Text('No notifications'));
// //         }

// //         return ListView.builder(
// //           itemCount: snapshot.data!.docs.length,
// //           itemBuilder: (context, index) {
// //             var notification = snapshot.data!.docs[index];
// //             return ListTile(
// //               title: Text(notification['title'] ?? ''),
// //               subtitle: Text(notification['body'] ?? ''),
// //               trailing: Text(
// //                 notification['timestamp'].toDate().toString(),
// //                 style: TextStyle(fontSize: 12),
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// // }

// //notification.dart
// // import 'package:flutter/material.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class NotificationScreen extends StatefulWidget {
// //   const NotificationScreen({Key? key}) : super(key: key);

// //   @override
// //   _NotificationScreenState createState() => _NotificationScreenState();
// // }

// // class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
// //   late TabController _tabController;
// //   final user = FirebaseAuth.instance.currentUser;
// //   List<DocumentSnapshot> myProductsNotifications = [];
// //   List<DocumentSnapshot> collectProductsNotifications = [];
// //   bool isLoading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 2, vsync: this);
// //     setupPushNotifications();
// //     fetchNotifications();
// //   }

// //   void setupPushNotifications() async {
// //     final fcm = FirebaseMessaging.instance;
// //     await fcm.requestPermission();
// //     final token = await fcm.getToken();
// //     print(token);
// //   }

// //   Future<void> fetchNotifications() async {
// //     try {
// //       final myProductsSnapshot = await FirebaseFirestore.instance
// //           .collection('notifications')
// //           .where('irID', isEqualTo: user?.uid)
// //           .where('type', isEqualTo: 'my_products')
// //           .orderBy('timestamp', descending: true)
// //           .get();

// //       final collectProductsSnapshot = await FirebaseFirestore.instance
// //           .collection('notifications')
// //           .where('irID', isEqualTo: user?.uid)
// //           .where('type', isEqualTo: 'collect_products')
// //           .orderBy('timestamp', descending: true)
// //           .get();

// //       setState(() {
// //         myProductsNotifications = myProductsSnapshot.docs;
// //         collectProductsNotifications = collectProductsSnapshot.docs;
// //         isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() {
// //         isLoading = false;
// //       });
// //       print('Error fetching notifications: $e');
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Notifications'),
// //         bottom: TabBar(
// //           controller: _tabController,
// //           tabs: const [
// //             Tab(text: 'My Products'),
// //             Tab(text: 'Collect Products'),
// //           ],
// //         ),
// //       ),
// //       body: isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : TabBarView(
// //               controller: _tabController,
// //               children: [
// //                 buildNotificationList(myProductsNotifications),
// //                 buildNotificationList(collectProductsNotifications),
// //               ],
// //             ),
// //     );
// //   }

// //   Widget buildNotificationList(List<DocumentSnapshot> notifications) {
// //     if (notifications.isEmpty) {
// //       return const Center(child: Text('No notifications'));
// //     }

// //     return ListView.builder(
// //       itemCount: notifications.length,
// //       itemBuilder: (context, index) {
// //         var notification = notifications[index];
// //         return ListTile(
// //           title: Text(notification['title'] ?? ''),
// //           subtitle: Text(notification['body'] ?? ''),
// //           trailing: Text(
// //             notification['timestamp'].toDate().toString(),
// //             style: TextStyle(fontSize: 12),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// // //notification.dart
// // import 'package:flutter/material.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class NotificationScreen extends StatefulWidget {
// //   const NotificationScreen({Key? key}) : super(key: key);

// //   @override
// //   _NotificationScreenState createState() => _NotificationScreenState();
// // }

// // class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
// //   late TabController _tabController;
// //   final user = FirebaseAuth.instance.currentUser;
// //   List<DocumentSnapshot> myProductsNotifications = [];
// //   List<DocumentSnapshot> collectProductsNotifications = [];
// //   bool isLoading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 2, vsync: this);
// //     setupPushNotifications();
// //     fetchNotifications();
// //   }

// //   void setupPushNotifications() async {
// //     final fcm = FirebaseMessaging.instance;
// //     await fcm.requestPermission();
// //     final token = await fcm.getToken();
// //     print(token);
// //   }

// //   Future<void> fetchNotifications() async {
// //     try {
// //       final myProductsSnapshot = await FirebaseFirestore.instance
// //           .collection('notifications')
// //           .where('irID', isEqualTo: user?.uid)
// //           .where('type', isEqualTo: 'my_products')
// //           .orderBy('timestamp', descending: true)
// //           .get();

// //       final collectProductsSnapshot = await FirebaseFirestore.instance
// //           .collection('notifications')
// //           .where('irID', isEqualTo: user?.uid)
// //           .where('type', isEqualTo: 'collect_products')
// //           .orderBy('timestamp', descending: true)
// //           .get();

// //       setState(() {
// //         myProductsNotifications = myProductsSnapshot.docs;
// //         collectProductsNotifications = collectProductsSnapshot.docs;
// //         isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() {
// //         isLoading = false;
// //       });
// //       print('Error fetching notifications: $e');
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Notifications'),
// //         bottom: TabBar(
// //           controller: _tabController,
// //           tabs: const [
// //             Tab(text: 'My Products'),
// //             Tab(text: 'Collect Products'),
// //           ],
// //         ),
// //       ),
// //       body: isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : TabBarView(
// //               controller: _tabController,
// //               children: [
// //                 buildNotificationList(myProductsNotifications),
// //                 buildNotificationList(collectProductsNotifications),
// //               ],
// //             ),
// //     );
// //   }

// //   Widget buildNotificationList(List<DocumentSnapshot> notifications) {
// //     if (notifications.isEmpty) {
// //       return const Center(child: Text('No notifications'));
// //     }

// //     return ListView.builder(
// //       itemCount: notifications.length,
// //       itemBuilder: (context, index) {
// //         var notification = notifications[index];
// //         return ListTile(
// //           title: Text(notification['title'] ?? ''),
// //           subtitle: Text(notification['body'] ?? ''),
// //           trailing: Text(
// //             notification['timestamp'].toDate().toString(),
// //             style: TextStyle(fontSize: 12),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// // //notification.dart
// // import 'package:flutter/material.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class NotificationScreen extends StatefulWidget {
// //   const NotificationScreen({Key? key}) : super(key: key);

// //   @override
// //   _NotificationScreenState createState() => _NotificationScreenState();
// // }

// // class _NotificationScreenState extends State<NotificationScreen>
// //     with SingleTickerProviderStateMixin {
// //   late TabController _tabController;
// //   final user = FirebaseAuth.instance.currentUser;
// //   List<DocumentSnapshot> myProductsNotifications = [];
// //   List<DocumentSnapshot> collectProductsNotifications = [];
// //   bool isLoading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 2, vsync: this);
// //     setupPushNotifications();
// //     fetchNotifications();
// //   }

// //   void setupPushNotifications() async {
// //     final fcm = FirebaseMessaging.instance;
// //     await fcm.requestPermission();
// //     final token = await fcm.getToken();
// //     print(token);
// //   }

// //   Future<void> fetchNotifications() async {
// //     try {
// //       final myProductsSnapshot = await FirebaseFirestore.instance
// //           .collection('notifications')
// //           .where('irID', isEqualTo: user?.uid)
// //           .where('type', isEqualTo: 'my_products')
// //           .orderBy('timestamp', descending: true)
// //           .get();

// //       final collectProductsSnapshot = await FirebaseFirestore.instance
// //           .collection('notifications')
// //           .where('irID', isEqualTo: user?.uid)
// //           .where('type', isEqualTo: 'collect_products')
// //           .orderBy('timestamp', descending: true)
// //           .get();

// //       setState(() {
// //         myProductsNotifications = myProductsSnapshot.docs;
// //         collectProductsNotifications = collectProductsSnapshot.docs;
// //         isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() {
// //         isLoading = false;
// //       });
// //       print('Error fetching notifications: $e');
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Notifications'),
// //         bottom: TabBar(
// //           controller: _tabController,
// //           tabs: const [
// //             Tab(text: 'My Products'),
// //             Tab(text: 'Collect Products'),
// //           ],
// //         ),
// //       ),
// //       body: TabBarView(
// //         controller: _tabController,
// //         children: [
// //           buildNotificationList('my_products'),
// //           buildNotificationList('collect_products'),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget buildNotificationList(String type) {
// //     return StreamBuilder<QuerySnapshot>(
// //       stream: FirebaseFirestore.instance
// //           .collection('notifications')
// //           .where('irID', isEqualTo: user?.uid)
// //           .where('type', isEqualTo: type)
// //           .orderBy('timestamp', descending: true)
// //           .snapshots(),
// //       builder: (context, snapshot) {
// //         print("StreamBuilder state: ${snapshot.connectionState}");
// //       print("Has data: ${snapshot.hasData}");
// //       print("Data length: ${snapshot.data?.docs.length ?? 'null'}");
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Center(child: CircularProgressIndicator());
// //         }

// //         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //           return const Center(child: Text('No notifications'));
// //         }
// //         if (snapshot.hasError) {
// //   print("Error in StreamBuilder: ${snapshot.error}");
// //   return Center(child: Text('Error: ${snapshot.error}'));
// // }

// //         return ListView.builder(
// //           itemCount: snapshot.data!.docs.length,
// //           itemBuilder: (context, index) {
// //             var notification = snapshot.data!.docs[index];
// //             return ListTile(
// //               title: Text(notification['title'] ?? ''),
// //               subtitle: Text(notification['body'] ?? ''),
// //               trailing: Text(
// //                 notification['timestamp'].toDate().toString(),
// //                 style: TextStyle(fontSize: 12),
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// // }

// //blaze.notification.dart
// // import 'package:flutter/material.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class NotificationScreen extends StatefulWidget {
// //   const NotificationScreen({Key? key}) : super(key: key);

// //   @override
// //   _NotificationScreenState createState() => _NotificationScreenState();
// // }

// // class _NotificationScreenState extends State<NotificationScreen>
// //     with SingleTickerProviderStateMixin {
// //   late TabController _tabController;
// //   final user = FirebaseAuth.instance.currentUser;
// //   List<DocumentSnapshot> myProductsNotifications = [];
// //   List<DocumentSnapshot> collectProductsNotifications = [];
// //   bool isLoading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 2, vsync: this);
// //     setupPushNotifications();
// //     fetchNotifications();
// //   }

// //   void saveTokenToDatabase(String token) async {
// //   final user = FirebaseAuth.instance.currentUser;
// //   if (user != null) {
// //     await FirebaseFirestore.instance
// //         .collection('IR')
// //         .doc(user.uid)
// //         .update({'fcmToken': token});
// //   }
// // }

// //   void setupPushNotifications() async {
// //     final fcm = FirebaseMessaging.instance;
// //     await fcm.requestPermission();
// //     final token = await fcm.getToken();
// //     print(token);

// //     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
// //       print('Message data: ${message.data}');
// //       if (message.notification != null) {
// //         print('Message also contained a notification: ${message.notification}');
// //       }
// //       // Display a local notification or update the UI as needed
// //     });

// //     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
// //       print('A new onMessageOpenedApp event was published!');
// //       Navigator.pushNamed(context, '/notificationScreen');
// //     });
// //   }

// //   Future<void> fetchNotifications() async {
// //     try {
// //       final myProductsSnapshot = await FirebaseFirestore.instance
// //           .collection('notifications')
// //           .where('irID', isEqualTo: user?.uid)
// //           .where('type', isEqualTo: 'my_products')
// //           .orderBy('timestamp', descending: true)
// //           .get();

// //       final collectProductsSnapshot = await FirebaseFirestore.instance
// //           .collection('notifications')
// //           .where('irID', isEqualTo: user?.uid)
// //           .where('type', isEqualTo: 'collect_products')
// //           .orderBy('timestamp', descending: true)
// //           .get();

// //       setState(() {
// //         myProductsNotifications = myProductsSnapshot.docs;
// //         collectProductsNotifications = collectProductsSnapshot.docs;
// //         isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() {
// //         isLoading = false;
// //       });
// //       print('Error fetching notifications: $e');
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Notifications'),
// //         bottom: TabBar(
// //           controller: _tabController,
// //           tabs: const [
// //             Tab(text: 'My Products'),
// //             Tab(text: 'Collect Products'),
// //           ],
// //         ),
// //       ),
// //       body: TabBarView(
// //         controller: _tabController,
// //         children: [
// //           buildNotificationList('my_products'),
// //           buildNotificationList('collect_products'),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget buildNotificationList(String type) {
// //     return StreamBuilder<QuerySnapshot>(
// //       stream: FirebaseFirestore.instance
// //           .collection('notifications')
// //           .where('irID', isEqualTo: user?.uid)
// //           .where('type', isEqualTo: type)
// //           .orderBy('timestamp', descending: true)
// //           .snapshots(),
// //       builder: (context, snapshot) {
// //         print("StreamBuilder state: ${snapshot.connectionState}");
// //         print("Has data: ${snapshot.hasData}");
// //         print("Data length: ${snapshot.data?.docs.length ?? 'null'}");
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Center(child: CircularProgressIndicator());
// //         }

// //         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //           return const Center(child: Text('No notifications'));
// //         }
// //         if (snapshot.hasError) {
// //           print("Error in StreamBuilder: ${snapshot.error}");
// //           return Center(child: Text('Error: ${snapshot.error}'));
// //         }

// //         return ListView.builder(
// //           itemCount: snapshot.data!.docs.length,
// //           itemBuilder: (context, index) {
// //             var notification = snapshot.data!.docs[index];
// //             return ListTile(
// //               title: Text(notification['title'] ?? ''),
// //               subtitle: Text(notification['body'] ?? ''),
// //               trailing: Text(
// //                 notification['timestamp'].toDate().toString(),
// //                 style: TextStyle(fontSize: 12),
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// // }

// // //fcm_notification.dart
// // import 'package:flutter/material.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class NotificationScreen extends StatefulWidget {
// //   const NotificationScreen({Key? key}) : super(key: key);

// //   @override
// //   _NotificationScreenState createState() => _NotificationScreenState();
// // }

// // class _NotificationScreenState extends State<NotificationScreen>
// //     with SingleTickerProviderStateMixin {
// //   late TabController _tabController;
// //   final user = FirebaseAuth.instance.currentUser;
// //   List<DocumentSnapshot> myProductsNotifications = [];
// //   List<DocumentSnapshot> collectProductsNotifications = [];
// //   bool isLoading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 2, vsync: this);
// //     setupPushNotifications();
// //     fetchNotifications();
// //   }

// //   void saveTokenToDatabase(String token) async {
// //   final user = FirebaseAuth.instance.currentUser;
// //   if (user != null) {
// //     await FirebaseFirestore.instance
// //         .collection('IR')
// //         .doc(user.uid)
// //         .update({'fcmToken': token});
// //   }
// // }

// //   void setupPushNotifications() async {
// //   final fcm = FirebaseMessaging.instance;
// //   await fcm.requestPermission();
// //   final token = await fcm.getToken();
// //   print("FCM Token: $token");

// //   if (token != null) {
// //     saveTokenToDatabase(token);
// //   }

// //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
// //     print("Received message: ${message.notification?.title}");
// //     // Refresh the notifications list
// //     setState(() {
// //       fetchNotifications();
// //     });
// //   });

// //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
// //     print("Opened app from notification: ${message.notification?.title}");
// //     // Navigate to the notifications page or refresh if already there
// //     Navigator.pushNamed(context, '/notifications');
// //   });
// // }

// //   Future<void> fetchNotifications() async {
// //     try {
// //       final myProductsSnapshot = await FirebaseFirestore.instance
// //           .collection('notifications')
// //           .where('irID', isEqualTo: user?.uid)
// //           .where('type', isEqualTo: 'my_products')
// //           .orderBy('timestamp', descending: true)
// //           .get();

// //       final collectProductsSnapshot = await FirebaseFirestore.instance
// //           .collection('notifications')
// //           .where('irID', isEqualTo: user?.uid)
// //           .where('type', isEqualTo: 'collect_products')
// //           .orderBy('timestamp', descending: true)
// //           .get();

// //       setState(() {
// //         myProductsNotifications = myProductsSnapshot.docs;
// //         collectProductsNotifications = collectProductsSnapshot.docs;
// //         isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() {
// //         isLoading = false;
// //       });
// //       print('Error fetching notifications: $e');
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Notifications'),
// //         bottom: TabBar(
// //           controller: _tabController,
// //           tabs: const [
// //             Tab(text: 'My Products'),
// //             Tab(text: 'Collect Products'),
// //           ],
// //         ),
// //       ),
// //       body: TabBarView(
// //         controller: _tabController,
// //         children: [
// //           buildNotificationList('my_products'),
// //           buildNotificationList('collect_products'),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget buildNotificationList(String type) {
// //     return StreamBuilder<QuerySnapshot>(
// //       stream: FirebaseFirestore.instance
// //           .collection('notifications')
// //           .where('irID', isEqualTo: user?.uid)
// //           .where('type', isEqualTo: type)
// //           .orderBy('timestamp', descending: true)
// //           .snapshots(),
// //       builder: (context, snapshot) {
// //         print("StreamBuilder state: ${snapshot.connectionState}");
// //         print("Has data: ${snapshot.hasData}");
// //         print("Data length: ${snapshot.data?.docs.length ?? 'null'}");
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Center(child: CircularProgressIndicator());
// //         }

// //         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //           return const Center(child: Text('No notifications'));
// //         }
// //         if (snapshot.hasError) {
// //           print("Error in StreamBuilder: ${snapshot.error}");
// //           return Center(child: Text('Error: ${snapshot.error}'));
// //         }

// //         return ListView.builder(
// //           itemCount: snapshot.data!.docs.length,
// //           itemBuilder: (context, index) {
// //             var notification = snapshot.data!.docs[index];
// //             return ListTile(
// //               title: Text(notification['title'] ?? ''),
// //               subtitle: Text(notification['body'] ?? ''),
// //               trailing: Text(
// //                 notification['timestamp'].toDate().toString(),
// //                 style: TextStyle(fontSize: 12),
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// // }

// // //fcm_notification.dart
// // import 'package:flutter/material.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:intl/intl.dart';
// // import 'package:vcon_3rdparty_auth/widgets/notification_item.dart';

// // class NotificationScreen extends StatefulWidget {
// //   const NotificationScreen({Key? key}) : super(key: key);

// //   @override
// //   _NotificationScreenState createState() => _NotificationScreenState();
// // }

// // class _NotificationScreenState extends State<NotificationScreen>
// //     with SingleTickerProviderStateMixin {
// //   late TabController _tabController;
// //   final user = FirebaseAuth.instance.currentUser;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 2, vsync: this);
// //     setupPushNotifications();
// //   }

// //   Future<void> saveUserFCMToken() async {
// //     final user = FirebaseAuth.instance.currentUser;
// //     if (user != null) {
// //       String? token = await FirebaseMessaging.instance.getToken();
// //       if (token != null) {
// //         await FirebaseFirestore.instance
// //             .collection('IR')
// //             .doc(user.uid)
// //             .update({'fcmToken': token});
// //         print('FCM Token saved successfully for user: ${user.uid}');
// //       }
// //     }
// //   }

// //   void setupPushNotifications() async {
// //     final fcm = FirebaseMessaging.instance;
// //     await fcm.requestPermission();
// //     await saveUserFCMToken();

// //     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
// //       print("Received message: ${message.notification?.title}");
// //       handleIncomingMessage(message);
// //     });

// //     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
// //       print("Opened app from notification: ${message.notification?.title}");
// //       handleIncomingMessage(message);
// //     });
// //   }

// //   void handleIncomingMessage(RemoteMessage message) {
// //     if (message.data['type'] == 'collect_products') {
// //       FirebaseFirestore.instance.collection('notifications').add({
// //         'collectorIRID': user?.uid,
// //         'type': 'collect_products',
// //         'title': message.notification?.title,
// //         'body': message.notification?.body,
// //         'timestamp': FieldValue.serverTimestamp(),
// //       }).then((docRef) {
// //         print("Notification saved successfully. Document ID: ${docRef.id}");
// //         setState(() {}); // Trigger a rebuild to reflect the new notification
// //       }).catchError((error) {
// //         print("Error saving notification: $error");
// //       });
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Notifications'),
// //         bottom: TabBar(
// //           controller: _tabController,
// //           tabs: const [
// //             Tab(text: 'My Products'),
// //             Tab(text: 'Collect Products'),
// //           ],
// //         ),
// //       ),
// //       body: TabBarView(
// //         controller: _tabController,
// //         children: [
// //           buildNotificationList('my_products'),
// //           buildNotificationList('collect_products'),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget buildNotificationList(String type) {
// //     return StreamBuilder<QuerySnapshot>(
// //       stream: FirebaseFirestore.instance
// //           .collection('notifications')
// //           .where('type', isEqualTo: type)
// //           .orderBy('timestamp', descending: true)
// //           .snapshots(),
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Center(child: CircularProgressIndicator());
// //         }

// //         if (snapshot.hasError) {
// //           return Center(child: Text('Error: ${snapshot.error}'));
// //         }

// //         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //           return const Center(child: Text('No notifications'));
// //         }

// //         return ListView.builder(
// //           itemCount: snapshot.data!.docs.length,
// //           itemBuilder: (context, index) {
// //             var notificationData = snapshot.data!.docs[index].data() as Map<String, dynamic>;

// //             var title = notificationData['title'] ?? 'No title';
// //             var body = notificationData['body'] ?? 'No body';
// //             var timestamp = notificationData['timestamp'] as Timestamp?;

// //             // Format the timestamp
// //             String timeString = 'No date';
// //             if (timestamp != null) {
// //               DateTime dateTime = timestamp.toDate();
// //               DateTime now = DateTime.now();

// //               if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
// //                 // If it's today, show time
// //                 timeString = DateFormat('HH:mm').format(dateTime);
// //               } else if (dateTime.year == now.year) {
// //                 // If it's this year, show date without year
// //                 timeString = DateFormat('MM/dd').format(dateTime);
// //               } else {
// //                 // Otherwise, show full date
// //                 timeString = DateFormat('yyyy/MM/dd').format(dateTime);
// //               }
// //             }

// //             return NotificationItem(
// //               title: title,
// //               body: body,
// //               timeString: timeString,
// //               isRead: false, // Adjust this if you have a field for read/unread status
// //               onTap: () {
// //                 // Handle tap if necessary
// //               },
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// // }

// //fcm_notification.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:vcon_3rdparty_auth/widgets/notification_item.dart';

// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({Key? key}) : super(key: key);

//   @override
//   _NotificationScreenState createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final user = FirebaseAuth.instance.currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     setupPushNotifications();
//   }

//   Future<void> saveUserFCMToken() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       String? token = await FirebaseMessaging.instance.getToken();
//       if (token != null) {
//         await FirebaseFirestore.instance
//             .collection('IR')
//             .doc(user.uid)
//             .update({'fcmToken': token});
//         print('FCM Token saved successfully for user: ${user.uid}');
//       }
//     }
//   }

//   void setupPushNotifications() async {
//     final fcm = FirebaseMessaging.instance;
//     await fcm.requestPermission();
//     await saveUserFCMToken();

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print("Received message: ${message.notification?.title}");
//       handleIncomingMessage(message);
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print("Opened app from notification: ${message.notification?.title}");
//       handleIncomingMessage(message);
//     });
//   }

//   void handleIncomingMessage(RemoteMessage message) {
//     String notificationType = message.data['type'] ?? 'collect_products';
//     FirebaseFirestore.instance.collection('notifications').add({
//       'collectorIRID': user?.uid,
//       'type': notificationType,
//       'title': message.notification?.title,
//       'body': message.notification?.body,
//       'timestamp': FieldValue.serverTimestamp(),
//       'isRead': false, // Add this line
//     }).then((docRef) {
//       print("Notification saved successfully. Document ID: ${docRef.id}");
//       setState(() {}); // Trigger a rebuild to reflect the new notification
//     }).catchError((error) {
//       print("Error saving notification: $error");
//     });
//   }

//   void markAsRead(DocumentSnapshot notificationDoc) {
//     notificationDoc.reference.update({'isRead': true});
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'My Products'),
//             Tab(text: 'Collect Products'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           buildNotificationList('my_products'),
//           buildNotificationList('collect_products'),
//         ],
//       ),
//     );
//   }

//   Widget buildNotificationList(String type) {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return const Center(child: Text('User not logged in'));

//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('notifications')
//           .where('collectorIRID', isEqualTo: user.uid)
//           .where('type', isEqualTo: type)
//           .orderBy('timestamp', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No notifications'));
//         }

//         return ListView.builder(
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             var notificationDoc = snapshot.data!.docs[index];
//             var notificationData =
//                 notificationDoc.data() as Map<String, dynamic>;

//             var title = notificationData['title'] ?? 'No title';
//             var body = notificationData['body'] ?? 'No body';
//             var timestamp = notificationData['timestamp'] as Timestamp?;
//             var isRead = notificationData['isRead'] ?? false;

//             // Format the timestamp
//             String timeString = 'No date';
//             if (timestamp != null) {
//               DateTime dateTime = timestamp.toDate();
//               DateTime now = DateTime.now();

//               if (dateTime.year == now.year &&
//                   dateTime.month == now.month &&
//                   dateTime.day == now.day) {
//                 // If it's today, show time
//                 timeString = DateFormat('HH:mm').format(dateTime);
//               } else if (dateTime.year == now.year) {
//                 // If it's this year, show date without year
//                 timeString = DateFormat('MM/dd').format(dateTime);
//               } else {
//                 // Otherwise, show full date
//                 timeString = DateFormat('yyyy/MM/dd').format(dateTime);
//               }
//             }

//             return NotificationItem(
//               title: title,
//               body: body,
//               timeString: timeString,
//               isRead: isRead,
//               onTap: () {
//                 markAsRead(notificationDoc);
//                 setState(() {}); // Trigger a rebuild to reflect the read status
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }

// //notification.dart
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({Key? key}) : super(key: key);

//   @override
//   _NotificationScreenState createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final user = FirebaseAuth.instance.currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);

//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'My Products'),
//             Tab(text: 'Collect Products'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           NotificationList(type: 'my_products'),
//           NotificationList(type: 'collect_products'),
//         ],
//       ),
//     );
//   }
// }

// class NotificationList extends StatelessWidget {
//   final String type;

//   const NotificationList({Key? key, required this.type}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('notifications')
//           .where('userID', isEqualTo: user?.uid)
//           .where('type', isEqualTo: type)
//           .orderBy('timestamp', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No notifications'));
//         }

//         return ListView.builder(
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             var notification = snapshot.data!.docs[index];
//             return ListTile(
//               title: Text(notification['title'] ?? ''),
//               subtitle: Text(notification['body'] ?? ''),
//               trailing: Text(
//                 notification['timestamp'].toDate().toString(),
//                 style: TextStyle(fontSize: 12),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

//notification.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({Key? key}) : super(key: key);

//   @override
//   _NotificationScreenState createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final user = FirebaseAuth.instance.currentUser;
//   List<DocumentSnapshot> myProductsNotifications = [];
//   List<DocumentSnapshot> collectProductsNotifications = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     setupPushNotifications();
//     fetchNotifications();
//   }

//   void setupPushNotifications() async {
//     final fcm = FirebaseMessaging.instance;
//     await fcm.requestPermission();
//     final token = await fcm.getToken();
//     print(token);
//   }

//   Future<void> fetchNotifications() async {
//     try {
//       final myProductsSnapshot = await FirebaseFirestore.instance
//           .collection('notifications')
//           .where('irID', isEqualTo: user?.uid)
//           .where('type', isEqualTo: 'my_products')
//           .orderBy('timestamp', descending: true)
//           .get();

//       final collectProductsSnapshot = await FirebaseFirestore.instance
//           .collection('notifications')
//           .where('irID', isEqualTo: user?.uid)
//           .where('type', isEqualTo: 'collect_products')
//           .orderBy('timestamp', descending: true)
//           .get();

//       setState(() {
//         myProductsNotifications = myProductsSnapshot.docs;
//         collectProductsNotifications = collectProductsSnapshot.docs;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print('Error fetching notifications: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'My Products'),
//             Tab(text: 'Collect Products'),
//           ],
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : TabBarView(
//               controller: _tabController,
//               children: [
//                 buildNotificationList(myProductsNotifications),
//                 buildNotificationList(collectProductsNotifications),
//               ],
//             ),
//     );
//   }

//   Widget buildNotificationList(List<DocumentSnapshot> notifications) {
//     if (notifications.isEmpty) {
//       return const Center(child: Text('No notifications'));
//     }

//     return ListView.builder(
//       itemCount: notifications.length,
//       itemBuilder: (context, index) {
//         var notification = notifications[index];
//         return ListTile(
//           title: Text(notification['title'] ?? ''),
//           subtitle: Text(notification['body'] ?? ''),
//           trailing: Text(
//             notification['timestamp'].toDate().toString(),
//             style: TextStyle(fontSize: 12),
//           ),
//         );
//       },
//     );
//   }
// }

// //notification.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({Key? key}) : super(key: key);

//   @override
//   _NotificationScreenState createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final user = FirebaseAuth.instance.currentUser;
//   List<DocumentSnapshot> myProductsNotifications = [];
//   List<DocumentSnapshot> collectProductsNotifications = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     setupPushNotifications();
//     fetchNotifications();
//   }

//   void setupPushNotifications() async {
//     final fcm = FirebaseMessaging.instance;
//     await fcm.requestPermission();
//     final token = await fcm.getToken();
//     print(token);
//   }

//   Future<void> fetchNotifications() async {
//     try {
//       final myProductsSnapshot = await FirebaseFirestore.instance
//           .collection('notifications')
//           .where('irID', isEqualTo: user?.uid)
//           .where('type', isEqualTo: 'my_products')
//           .orderBy('timestamp', descending: true)
//           .get();

//       final collectProductsSnapshot = await FirebaseFirestore.instance
//           .collection('notifications')
//           .where('irID', isEqualTo: user?.uid)
//           .where('type', isEqualTo: 'collect_products')
//           .orderBy('timestamp', descending: true)
//           .get();

//       setState(() {
//         myProductsNotifications = myProductsSnapshot.docs;
//         collectProductsNotifications = collectProductsSnapshot.docs;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print('Error fetching notifications: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'My Products'),
//             Tab(text: 'Collect Products'),
//           ],
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : TabBarView(
//               controller: _tabController,
//               children: [
//                 buildNotificationList(myProductsNotifications),
//                 buildNotificationList(collectProductsNotifications),
//               ],
//             ),
//     );
//   }

//   Widget buildNotificationList(List<DocumentSnapshot> notifications) {
//     if (notifications.isEmpty) {
//       return const Center(child: Text('No notifications'));
//     }

//     return ListView.builder(
//       itemCount: notifications.length,
//       itemBuilder: (context, index) {
//         var notification = notifications[index];
//         return ListTile(
//           title: Text(notification['title'] ?? ''),
//           subtitle: Text(notification['body'] ?? ''),
//           trailing: Text(
//             notification['timestamp'].toDate().toString(),
//             style: TextStyle(fontSize: 12),
//           ),
//         );
//       },
//     );
//   }
// }

// //notification.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({Key? key}) : super(key: key);

//   @override
//   _NotificationScreenState createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final user = FirebaseAuth.instance.currentUser;
//   List<DocumentSnapshot> myProductsNotifications = [];
//   List<DocumentSnapshot> collectProductsNotifications = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     setupPushNotifications();
//     fetchNotifications();
//   }

//   void setupPushNotifications() async {
//     final fcm = FirebaseMessaging.instance;
//     await fcm.requestPermission();
//     final token = await fcm.getToken();
//     print(token);
//   }

//   Future<void> fetchNotifications() async {
//     try {
//       final myProductsSnapshot = await FirebaseFirestore.instance
//           .collection('notifications')
//           .where('irID', isEqualTo: user?.uid)
//           .where('type', isEqualTo: 'my_products')
//           .orderBy('timestamp', descending: true)
//           .get();

//       final collectProductsSnapshot = await FirebaseFirestore.instance
//           .collection('notifications')
//           .where('irID', isEqualTo: user?.uid)
//           .where('type', isEqualTo: 'collect_products')
//           .orderBy('timestamp', descending: true)
//           .get();

//       setState(() {
//         myProductsNotifications = myProductsSnapshot.docs;
//         collectProductsNotifications = collectProductsSnapshot.docs;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print('Error fetching notifications: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'My Products'),
//             Tab(text: 'Collect Products'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           buildNotificationList('my_products'),
//           buildNotificationList('collect_products'),
//         ],
//       ),
//     );
//   }

//   Widget buildNotificationList(String type) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('notifications')
//           .where('irID', isEqualTo: user?.uid)
//           .where('type', isEqualTo: type)
//           .orderBy('timestamp', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         print("StreamBuilder state: ${snapshot.connectionState}");
//       print("Has data: ${snapshot.hasData}");
//       print("Data length: ${snapshot.data?.docs.length ?? 'null'}");
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No notifications'));
//         }
//         if (snapshot.hasError) {
//   print("Error in StreamBuilder: ${snapshot.error}");
//   return Center(child: Text('Error: ${snapshot.error}'));
// }

//         return ListView.builder(
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             var notification = snapshot.data!.docs[index];
//             return ListTile(
//               title: Text(notification['title'] ?? ''),
//               subtitle: Text(notification['body'] ?? ''),
//               trailing: Text(
//                 notification['timestamp'].toDate().toString(),
//                 style: TextStyle(fontSize: 12),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

//blaze.notification.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({Key? key}) : super(key: key);

//   @override
//   _NotificationScreenState createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final user = FirebaseAuth.instance.currentUser;
//   List<DocumentSnapshot> myProductsNotifications = [];
//   List<DocumentSnapshot> collectProductsNotifications = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     setupPushNotifications();
//     fetchNotifications();
//   }

//   void saveTokenToDatabase(String token) async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user != null) {
//     await FirebaseFirestore.instance
//         .collection('IR')
//         .doc(user.uid)
//         .update({'fcmToken': token});
//   }
// }

//   void setupPushNotifications() async {
//     final fcm = FirebaseMessaging.instance;
//     await fcm.requestPermission();
//     final token = await fcm.getToken();
//     print(token);

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Message data: ${message.data}');
//       if (message.notification != null) {
//         print('Message also contained a notification: ${message.notification}');
//       }
//       // Display a local notification or update the UI as needed
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('A new onMessageOpenedApp event was published!');
//       Navigator.pushNamed(context, '/notificationScreen');
//     });
//   }

//   Future<void> fetchNotifications() async {
//     try {
//       final myProductsSnapshot = await FirebaseFirestore.instance
//           .collection('notifications')
//           .where('irID', isEqualTo: user?.uid)
//           .where('type', isEqualTo: 'my_products')
//           .orderBy('timestamp', descending: true)
//           .get();

//       final collectProductsSnapshot = await FirebaseFirestore.instance
//           .collection('notifications')
//           .where('irID', isEqualTo: user?.uid)
//           .where('type', isEqualTo: 'collect_products')
//           .orderBy('timestamp', descending: true)
//           .get();

//       setState(() {
//         myProductsNotifications = myProductsSnapshot.docs;
//         collectProductsNotifications = collectProductsSnapshot.docs;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print('Error fetching notifications: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'My Products'),
//             Tab(text: 'Collect Products'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           buildNotificationList('my_products'),
//           buildNotificationList('collect_products'),
//         ],
//       ),
//     );
//   }

//   Widget buildNotificationList(String type) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('notifications')
//           .where('irID', isEqualTo: user?.uid)
//           .where('type', isEqualTo: type)
//           .orderBy('timestamp', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         print("StreamBuilder state: ${snapshot.connectionState}");
//         print("Has data: ${snapshot.hasData}");
//         print("Data length: ${snapshot.data?.docs.length ?? 'null'}");
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No notifications'));
//         }
//         if (snapshot.hasError) {
//           print("Error in StreamBuilder: ${snapshot.error}");
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         return ListView.builder(
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             var notification = snapshot.data!.docs[index];
//             return ListTile(
//               title: Text(notification['title'] ?? ''),
//               subtitle: Text(notification['body'] ?? ''),
//               trailing: Text(
//                 notification['timestamp'].toDate().toString(),
//                 style: TextStyle(fontSize: 12),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// //fcm_notification.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({Key? key}) : super(key: key);

//   @override
//   _NotificationScreenState createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final user = FirebaseAuth.instance.currentUser;
//   List<DocumentSnapshot> myProductsNotifications = [];
//   List<DocumentSnapshot> collectProductsNotifications = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     setupPushNotifications();
//     fetchNotifications();
//   }

//   void saveTokenToDatabase(String token) async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user != null) {
//     await FirebaseFirestore.instance
//         .collection('IR')
//         .doc(user.uid)
//         .update({'fcmToken': token});
//   }
// }

//   void setupPushNotifications() async {
//   final fcm = FirebaseMessaging.instance;
//   await fcm.requestPermission();
//   final token = await fcm.getToken();
//   print("FCM Token: $token");

//   if (token != null) {
//     saveTokenToDatabase(token);
//   }

//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print("Received message: ${message.notification?.title}");
//     // Refresh the notifications list
//     setState(() {
//       fetchNotifications();
//     });
//   });

//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print("Opened app from notification: ${message.notification?.title}");
//     // Navigate to the notifications page or refresh if already there
//     Navigator.pushNamed(context, '/notifications');
//   });
// }

//   Future<void> fetchNotifications() async {
//     try {
//       final myProductsSnapshot = await FirebaseFirestore.instance
//           .collection('notifications')
//           .where('irID', isEqualTo: user?.uid)
//           .where('type', isEqualTo: 'my_products')
//           .orderBy('timestamp', descending: true)
//           .get();

//       final collectProductsSnapshot = await FirebaseFirestore.instance
//           .collection('notifications')
//           .where('irID', isEqualTo: user?.uid)
//           .where('type', isEqualTo: 'collect_products')
//           .orderBy('timestamp', descending: true)
//           .get();

//       setState(() {
//         myProductsNotifications = myProductsSnapshot.docs;
//         collectProductsNotifications = collectProductsSnapshot.docs;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print('Error fetching notifications: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'My Products'),
//             Tab(text: 'Collect Products'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           buildNotificationList('my_products'),
//           buildNotificationList('collect_products'),
//         ],
//       ),
//     );
//   }

//   Widget buildNotificationList(String type) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('notifications')
//           .where('irID', isEqualTo: user?.uid)
//           .where('type', isEqualTo: type)
//           .orderBy('timestamp', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         print("StreamBuilder state: ${snapshot.connectionState}");
//         print("Has data: ${snapshot.hasData}");
//         print("Data length: ${snapshot.data?.docs.length ?? 'null'}");
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No notifications'));
//         }
//         if (snapshot.hasError) {
//           print("Error in StreamBuilder: ${snapshot.error}");
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         return ListView.builder(
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             var notification = snapshot.data!.docs[index];
//             return ListTile(
//               title: Text(notification['title'] ?? ''),
//               subtitle: Text(notification['body'] ?? ''),
//               trailing: Text(
//                 notification['timestamp'].toDate().toString(),
//                 style: TextStyle(fontSize: 12),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// //fcm_notification.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:vcon_3rdparty_auth/widgets/notification_item.dart';

// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({Key? key}) : super(key: key);

//   @override
//   _NotificationScreenState createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final user = FirebaseAuth.instance.currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     setupPushNotifications();
//   }

//   Future<void> saveUserFCMToken() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       String? token = await FirebaseMessaging.instance.getToken();
//       if (token != null) {
//         await FirebaseFirestore.instance
//             .collection('IR')
//             .doc(user.uid)
//             .update({'fcmToken': token});
//         print('FCM Token saved successfully for user: ${user.uid}');
//       }
//     }
//   }

//   void setupPushNotifications() async {
//     final fcm = FirebaseMessaging.instance;
//     await fcm.requestPermission();
//     await saveUserFCMToken();

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print("Received message: ${message.notification?.title}");
//       handleIncomingMessage(message);
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print("Opened app from notification: ${message.notification?.title}");
//       handleIncomingMessage(message);
//     });
//   }

//   void handleIncomingMessage(RemoteMessage message) {
//     if (message.data['type'] == 'collect_products') {
//       FirebaseFirestore.instance.collection('notifications').add({
//         'collectorIRID': user?.uid,
//         'type': 'collect_products',
//         'title': message.notification?.title,
//         'body': message.notification?.body,
//         'timestamp': FieldValue.serverTimestamp(),
//       }).then((docRef) {
//         print("Notification saved successfully. Document ID: ${docRef.id}");
//         setState(() {}); // Trigger a rebuild to reflect the new notification
//       }).catchError((error) {
//         print("Error saving notification: $error");
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'My Products'),
//             Tab(text: 'Collect Products'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           buildNotificationList('my_products'),
//           buildNotificationList('collect_products'),
//         ],
//       ),
//     );
//   }

//   Widget buildNotificationList(String type) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('notifications')
//           .where('type', isEqualTo: type)
//           .orderBy('timestamp', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No notifications'));
//         }

//         return ListView.builder(
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             var notificationData = snapshot.data!.docs[index].data() as Map<String, dynamic>;

//             var title = notificationData['title'] ?? 'No title';
//             var body = notificationData['body'] ?? 'No body';
//             var timestamp = notificationData['timestamp'] as Timestamp?;

//             // Format the timestamp
//             String timeString = 'No date';
//             if (timestamp != null) {
//               DateTime dateTime = timestamp.toDate();
//               DateTime now = DateTime.now();

//               if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
//                 // If it's today, show time
//                 timeString = DateFormat('HH:mm').format(dateTime);
//               } else if (dateTime.year == now.year) {
//                 // If it's this year, show date without year
//                 timeString = DateFormat('MM/dd').format(dateTime);
//               } else {
//                 // Otherwise, show full date
//                 timeString = DateFormat('yyyy/MM/dd').format(dateTime);
//               }
//             }

//             return NotificationItem(
//               title: title,
//               body: body,
//               timeString: timeString,
//               isRead: false, // Adjust this if you have a field for read/unread status
//               onTap: () {
//                 // Handle tap if necessary
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }

// //fcm_notification.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:vcon_3rdparty_auth/widgets/notification_item.dart';

// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({Key? key}) : super(key: key);

//   @override
//   _NotificationScreenState createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final user = FirebaseAuth.instance.currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     setupPushNotifications();
//   }

//   Future<void> saveUserFCMToken() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       String? token = await FirebaseMessaging.instance.getToken();
//       if (token != null) {
//         await FirebaseFirestore.instance
//             .collection('IR')
//             .where('email', isEqualTo: user.email) // Assume email is unique and exists in IR
//             .get()
//             .then((querySnapshot) {
//               if (querySnapshot.docs.isNotEmpty) {
//                 querySnapshot.docs.first.reference.update({'fcmToken': token});
//                 print('FCM Token saved successfully for user: ${user.uid}');
//               } else {
//                 print('No user found in IR collection with email: ${user.email}');
//               }
//             });
//       }
//     }
//   }

//   void setupPushNotifications() async {
//     final fcm = FirebaseMessaging.instance;
//     await fcm.requestPermission();
//     await saveUserFCMToken();

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print("Received message: ${message.notification?.title}");
//       handleIncomingMessage(message);
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print("Opened app from notification: ${message.notification?.title}");
//       handleIncomingMessage(message);
//     });
//   }

//   void handleIncomingMessage(RemoteMessage message) {
//     String notificationType = message.data['type'] ?? 'collect_products';
//     String assignerIRID = message.data['assignerIRID'] ?? '';

//     print("Received notification - Type: $notificationType, Assigner IRID: $assignerIRID");

//     FirebaseFirestore.instance.collection('notifications').add({
//       'collectorIRID': user?.uid,
//       'irID': assignerIRID,
//       'type': notificationType,
//       'title': message.notification?.title ?? 'No Title',
//       'body': message.notification?.body ?? 'No Body',
//       'timestamp': FieldValue.serverTimestamp(),
//       'isRead': false,
//     }).then((docRef) {
//       print("Notification saved successfully. Document ID: ${docRef.id}");
//       setState(() {}); // Trigger a rebuild to reflect the new notification
//     }).catchError((error) {
//       print("Error saving notification: $error");
//     });
//   }

//   void markAsRead(DocumentSnapshot notificationDoc) {
//     notificationDoc.reference.update({'isRead': true}).then((_) {
//       print('Notification marked as read: ${notificationDoc.id}');
//     }).catchError((error) {
//       print('Error marking notification as read: $error');
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'My Products'),
//             Tab(text: 'Collect Products'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           buildNotificationList('my_products'),
//           buildNotificationList('collect_products'),
//         ],
//       ),
//     );
//   }

//   Widget buildNotificationList(String type) {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) {
//     print('User not logged in');
//     return const Center(child: Text('User not logged in'));
//   }

//   print('Building notification list for type: $type');
//   print('Current user UID: ${user.uid}');

//   return FutureBuilder<QuerySnapshot>(
//     future: FirebaseFirestore.instance
//         .collection('IR')
//         .where('email', isEqualTo: user.email) // Assume email is unique and exists in IR
//         .get(),
//     builder: (context, userSnapshot) {
//       if (userSnapshot.connectionState == ConnectionState.waiting) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       if (userSnapshot.hasError) {
//         print('Error fetching user data: ${userSnapshot.error}');
//         return Center(child: Text('Error: ${userSnapshot.error}'));
//       }

//       if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
//         print('User data not found');
//         return const Center(child: Text('User data not found'));
//       }

//       print('User document data: ${userSnapshot.data!.docs.first.data()}');

//       String userIRID = userSnapshot.data!.docs.first.get('irID');
//       print('User IRID: $userIRID');

//       Query notificationsQuery = FirebaseFirestore.instance
//           .collection('notifications')
//           .orderBy('timestamp', descending: true);

//       if (type == 'my_products') {
//         notificationsQuery = notificationsQuery.where('irID', isEqualTo: userIRID);
//       } else if (type == 'collect_products') {
//         notificationsQuery = notificationsQuery.where('collectorIRID', isEqualTo: userIRID);
//       }

//       return StreamBuilder<QuerySnapshot>(
//         stream: notificationsQuery.snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             print('Error in StreamBuilder: ${snapshot.error}');
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             print('No notifications found for $type');
//             return Center(child: Text('No notifications for $type'));
//           }

//           print('Number of notifications for $type: ${snapshot.data!.docs.length}');

//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               var notificationDoc = snapshot.data!.docs[index];
//               var notificationData = notificationDoc.data() as Map<String, dynamic>;

//               print('Notification data: $notificationData');

//               var title = notificationData['title'] ?? 'No title';
//               var body = notificationData['body'] ?? 'No body';
//               var isRead = notificationData['isRead'] ?? false;
//               var timestamp = notificationData['timestamp'] as Timestamp?;

//               // Format the timestamp to a readable string
//               String timeString = timestamp != null
//                   ? DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate())
//                   : 'Unknown time';

//               return NotificationItem(
//                 title: title,
//                 body: body,
//                 timeString: timeString,
//                 isRead: isRead,
//                 onTap: () => markAsRead(notificationDoc),
//               );
//             },
//           );
//         },
//       );
//     },
//   );
// }
// }

// //fcm_notification.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:vcon_3rdparty_auth/widgets/notification_item.dart';
// import 'package:vcon_3rdparty_auth/screens/notification_total.dart';

// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({Key? key}) : super(key: key);

//   @override
//   _NotificationScreenState createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen>
//     with SingleTickerProviderStateMixin {
//       int _unreadMyProducts = 0;
//       int _unreadCollectProducts = 0;
//       late TabController _tabController;
//       final user = FirebaseAuth.instance.currentUser;

//       @override
//       void initState() {
//         super.initState();
//         _tabController = TabController(length: 2, vsync: this);
//         setupPushNotifications();
//         updateUnreadCounts();

//         _tabController.addListener(() {
//           if (!_tabController.indexIsChanging) {
//             updateUnreadCounts();
//           }
//         });
//       }

//       Future<void> saveUserFCMToken() async {
//         final user = FirebaseAuth.instance.currentUser;
//         if (user != null) {
//           String? token = await FirebaseMessaging.instance.getToken();
//           if (token != null) {
//             await FirebaseFirestore.instance
//                 .collection('IR')
//                 .where('email',
//                     isEqualTo:
//                         user.email) // Assume email is unique and exists in IR
//                 .get()
//                 .then((querySnapshot) {
//               if (querySnapshot.docs.isNotEmpty) {
//                 querySnapshot.docs.first.reference.update({'fcmToken': token});
//                 print('FCM Token saved successfully for user: ${user.uid}');
//               } else {
//                 print('No user found in IR collection with email: ${user.email}');
//               }
//             });
//           }
//         }
//       }

//       void setupPushNotifications() async {
//         final fcm = FirebaseMessaging.instance;
//         await fcm.requestPermission();
//         await saveUserFCMToken();

//         FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//           print("Received message: ${message.notification?.title}");
//           handleIncomingMessage(message);
//         });

//         FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//           print("Opened app from notification: ${message.notification?.title}");
//           handleIncomingMessage(message);
//         });
//       }

//       // void handleIncomingMessage(RemoteMessage message) {
//       //   String notificationType = message.data['type'] ?? 'collect_products';
//       //   String assignerIRID = message.data['assignerIRID'] ?? '';

//       //   print(
//       //       "Received notification - Type: $notificationType, Assigner IRID: $assignerIRID");

//       //   FirebaseFirestore.instance.collection('notifications').add({
//       //     'collectorIRID': user?.uid,
//       //     'irID': assignerIRID,
//       //     'type': notificationType,
//       //     'title': message.notification?.title ?? 'No Title',
//       //     'body': message.notification?.body ?? 'No Body',
//       //     'timestamp': FieldValue.serverTimestamp(),
//       //     'isRead': false,
//       //   }).then((docRef) {
//       //     print("Notification saved successfully. Document ID: ${docRef.id}");
//       //     updateUnreadCounts();
//       //     //setState(() {}); // Trigger a rebuild to reflect the new notification
//       //   }).catchError((error) {
//       //     print("Error saving notification: $error");
//       //   });
//       // }

//       void handleIncomingMessage(RemoteMessage message) async {
//   String notificationType = message.data['type'] ?? 'collect_products';
//   String assignerIRID = message.data['assignerIRID'] ?? '';

//   print("Received notification - Type: $notificationType, Assigner IRID: $assignerIRID");

//   // Get the current user's IRID
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) {
//     print('User not logged in');
//     return;
//   }

//   DocumentSnapshot userDoc = await FirebaseFirestore.instance
//       .collection('IR')
//       .where('email', isEqualTo: user.email)
//       .get()
//       .then((snapshot) => snapshot.docs.first);

//   if (!userDoc.exists) {
//     print('User document does not exist');
//     return;
//   }

//   String userIRID = userDoc.get('irID');

//   // Now proceed with saving the notification
//   try {
//     await FirebaseFirestore.instance.collection('notifications').add({
//       'collectorIRID': userIRID,
//       'irID': assignerIRID,
//       'type': notificationType,
//       'title': message.notification?.title ?? 'No Title',
//       'body': message.notification?.body ?? 'No Body',
//       'timestamp': FieldValue.serverTimestamp(),
//       'isRead': false,
//     });
    
//     print("Notification saved successfully.");
//     updateUnreadCounts();
//   } catch (error) {
//     print("Error saving notification: $error");
//   }
// }

//       void markAsRead(DocumentSnapshot notificationDoc) {
//         notificationDoc.reference.update({'isRead': true}).then((_) {
//           print('Notification marked as read: ${notificationDoc.id}');
//           updateUnreadCounts();
//         }).catchError((error) {
//           print('Error marking notification as read: $error');
//         });
//       }

//       void updateUnreadCounts() async {
//         final user = FirebaseAuth.instance.currentUser;
//         if (user == null) return;

//         DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('IR')
//             .where('email', isEqualTo: user.email)
//             .get()
//             .then((snapshot) => snapshot.docs.first);

//         String userIRID = userDoc.get('irID');

//         QuerySnapshot myProductsUnread = await FirebaseFirestore.instance
//             .collection('notifications')
//             .where('isRead', isEqualTo: false)
//             .where('irID', isEqualTo: userIRID)
//             .where('type', isEqualTo: 'my_products')
//             .get();

//         QuerySnapshot collectProductsUnread = await FirebaseFirestore.instance
//             .collection('notifications')
//             .where('isRead', isEqualTo: false)
//             .where('collectorIRID', isEqualTo: userIRID)
//             .where('type', isEqualTo: 'collect_products')
//             .get();

//         setState(() {
//           _unreadMyProducts = myProductsUnread.docs.length;
//           _unreadCollectProducts = collectProductsUnread.docs.length;
//           // Update the total unread count
//           NotificationTotal().totalUnreadCount = _unreadMyProducts + _unreadCollectProducts;
//         });

//         print("Unread My Products: $_unreadMyProducts");
//         print("Unread Collect Products: $_unreadCollectProducts");
//         print("Total Unread: ${NotificationTotal().totalUnreadCount}");
//       }

//       @override
//       void dispose() {
//         _tabController.dispose();
//         super.dispose();
//       }

//       @override
//       Widget build(BuildContext context) {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Notifications'),
//             bottom: TabBar(
//               controller: _tabController,
//               indicatorColor: const Color.fromARGB(111, 66, 144, 208),
//               tabs: [
//                 Tab(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'My Products',
//                         style: TextStyle(
//                           color: _tabController.index == 0 ? Colors.black : Colors.grey,
//                         ),
//                       ),
//                       if (_unreadMyProducts > 0)
//                         Container(
//                           margin: const EdgeInsets.only(left: 5),
//                           padding: const EdgeInsets.all(2),
//                           decoration: BoxDecoration(
//                             color: Colors.red,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           constraints: const BoxConstraints(
//                             minWidth: 16,
//                             minHeight: 16,
//                           ),
//                           child: Text(
//                             '$_unreadMyProducts',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 Tab(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Collect Products',
//                         style: TextStyle(
//                           color: _tabController.index == 1 ? Colors.black : Colors.grey,
//                         ),
//                       ),
                      
//                       if (_unreadCollectProducts > 0)
//                         Container(
//                           margin: const EdgeInsets.only(left: 5),
//                           padding: const EdgeInsets.all(2),
//                           decoration: BoxDecoration(
//                             color: Colors.red,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           constraints: const BoxConstraints(
//                             minWidth: 16,
//                             minHeight: 16,
//                           ),
//                           child: Text(
//                             '$_unreadCollectProducts',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           body: TabBarView(
//             controller: _tabController,
//             children: [
//               buildNotificationList('my_products'),
//               buildNotificationList('collect_products'),
//             ],
//           ),
//         );
//       }

//       Widget buildNotificationList(String type) {
//         final user = FirebaseAuth.instance.currentUser;
//         if (user == null) {
//           print('User not logged in');
//           return const Center(child: Text('User not logged in'));
//         }

//         print('Building notification list for type: $type');
//         print('Current user UID: ${user.uid}');

//         return FutureBuilder<QuerySnapshot>(
//           future: FirebaseFirestore.instance
//               .collection('IR')
//               .where('email',
//                   isEqualTo: user.email) // Assume email is unique and exists in IR
//               .get(),
//           builder: (context, userSnapshot) {
//             if (userSnapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (userSnapshot.hasError) {
//               print('Error fetching user data: ${userSnapshot.error}');
//               return Center(child: Text('Error: ${userSnapshot.error}'));
//             }

//             if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
//               print('User data not found');
//               return const Center(child: Text('User data not found'));
//             }

//             print('User document data: ${userSnapshot.data!.docs.first.data()}');

//             String userIRID = userSnapshot.data!.docs.first.get('irID');
//             print('User IRID: $userIRID');

//             Query notificationsQuery = FirebaseFirestore.instance
//                 .collection('notifications')
//                 .orderBy('timestamp', descending: true);

//             if (type == 'my_products') {
//               notificationsQuery = notificationsQuery
//                   .where('irID', isEqualTo: userIRID)
//                   .where('type', isEqualTo: 'my_products');
//             } else if (type == 'collect_products') {
//               notificationsQuery = notificationsQuery
//                   .where('collectorIRID', isEqualTo: userIRID)
//                   .where('type', isEqualTo: 'collect_products');
//             }

//             return StreamBuilder<QuerySnapshot>(
//               stream: notificationsQuery.snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (snapshot.hasError) {
//                   print('Error in StreamBuilder: ${snapshot.error}');
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   print('No notifications found for $type');
//                   return Center(child: Text('No notifications for $type'));
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   print('No notifications found for $type');
//                   // Update unread count to 0 for this type
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     setState(() {
//                       if (type == 'my_products') {
//                         _unreadMyProducts = 0;
//                       } else if (type == 'collect_products') {
//                         _unreadCollectProducts = 0;
//                       }
//                     });
//                   });
//                   return Center(child: Text('No notifications for $type'));
//                 }

//                 print(
//                     'Number of notifications for $type: ${snapshot.data!.docs.length}');

//                 return ListView.builder(
//                   itemCount: snapshot.data!.docs.length,
//                   itemBuilder: (context, index) {
//                     var notificationDoc = snapshot.data!.docs[index];
//                     var notificationData =
//                         notificationDoc.data() as Map<String, dynamic>;

//                     print('Notification data: $notificationData');

//                     var title = notificationData['title'] ?? 'No title';
//                     var body = notificationData['body'] ?? 'No body';
//                     var isRead = notificationData['isRead'] ?? false;
//                     var timestamp = notificationData['timestamp'] as Timestamp?;

//                     String timeString = '';
//                     String dateString = '';
//                     if (timestamp != null) {
//                       timeString = DateFormat('HH:mm').format(timestamp.toDate());
//                       dateString = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
//                     }

//                     return NotificationItem(
//                       title: title,
//                       body: body,
//                       timeString: timeString,
//                       dateString: dateString,
//                       isRead: isRead,
//                       onTap: () => markAsRead(notificationDoc),
//                     );
//                   },
//                 );
//               },
//             );
//           },
//         );
//       }
//     }

//fcm_notification.dart
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:vcon_3rdparty_auth/widgets/notification_item.dart';
import 'package:vcon_3rdparty_auth/screens/notification_total.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
      int _unreadMyProducts = 0;
      int _unreadCollectProducts = 0;
      late TabController _tabController;
      final user = FirebaseAuth.instance.currentUser;

      @override
      void initState() {
        super.initState();
        _tabController = TabController(length: 2, vsync: this);
        setupPushNotifications();
        updateUnreadCounts();

        _tabController.addListener(() {
          if (!_tabController.indexIsChanging) {
            updateUnreadCounts();
          }
        });
      }

      Future<void> saveUserFCMToken() async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String? token = await FirebaseMessaging.instance.getToken();
          if (token != null) {
            await FirebaseFirestore.instance
                .collection('IR')
                .where('email',
                    isEqualTo:
                        user.email) // Assume email is unique and exists in IR
                .get()
                .then((querySnapshot) {
              if (querySnapshot.docs.isNotEmpty) {
                querySnapshot.docs.first.reference.update({'fcmToken': token});
                print('FCM Token saved successfully for user: ${user.uid}');
              } else {
                print('No user found in IR collection with email: ${user.email}');
              }
            });
          }
        }
      }

      void setupPushNotifications() async {
        final fcm = FirebaseMessaging.instance;
        await fcm.requestPermission();
        await saveUserFCMToken();

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print("Received message: ${message.notification?.title}");
          handleIncomingMessage(message);
        });

        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print("Opened app from notification: ${message.notification?.title}");
          handleIncomingMessage(message);
        });
      }

      // void handleIncomingMessage(RemoteMessage message) {
      //   String notificationType = message.data['type'] ?? 'collect_products';
      //   String assignerIRID = message.data['assignerIRID'] ?? '';

      //   print(
      //       "Received notification - Type: $notificationType, Assigner IRID: $assignerIRID");

      //   FirebaseFirestore.instance.collection('notifications').add({
      //     'collectorIRID': user?.uid,
      //     'irID': assignerIRID,
      //     'type': notificationType,
      //     'title': message.notification?.title ?? 'No Title',
      //     'body': message.notification?.body ?? 'No Body',
      //     'timestamp': FieldValue.serverTimestamp(),
      //     'isRead': false,
      //   }).then((docRef) {
      //     print("Notification saved successfully. Document ID: ${docRef.id}");
      //     updateUnreadCounts();
      //     //setState(() {}); // Trigger a rebuild to reflect the new notification
      //   }).catchError((error) {
      //     print("Error saving notification: $error");
      //   });
      // }

      void handleIncomingMessage(RemoteMessage message) async {
        String notificationType = message.data['type'] ?? 'collect_products';
        String assignerIRID = message.data['assignerIRID'] ?? '';
        String collectorIRID = message.data['collectorIRID'] ?? '';

        print("Received notification - Type: $notificationType, Assigner IRID: $assignerIRID, Collector IRID: $collectorIRID");

        // Get the current user's IRID
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          print('User not logged in');
          return;
        }

        try {
          QuerySnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('IR')
              .where('email', isEqualTo: user.email)
              .limit(1)
              .get();

          if (userSnapshot.docs.isEmpty) {
            print('User document does not exist');
            return;
          }

          String userIRID = userSnapshot.docs.first.get('irID');

          // Now proceed with saving the notification
          await FirebaseFirestore.instance.collection('notifications').add({
            'collectorIRID': collectorIRID.isNotEmpty ? collectorIRID : userIRID,
            'irID': assignerIRID,
            'type': notificationType,
            'title': message.notification?.title ?? 'No Title',
            'body': message.notification?.body ?? 'No Body',
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
          });
          
          print("Notification saved successfully.");
          updateUnreadCounts();
        } catch (error) {
          print("Error saving notification: $error");
        }
      }

      void markAsRead(DocumentSnapshot notificationDoc) {
        notificationDoc.reference.update({'isRead': true}).then((_) {
          print('Notification marked as read: ${notificationDoc.id}');
          updateUnreadCounts();
        }).catchError((error) {
          print('Error marking notification as read: $error');
        });
      }

      void updateUnreadCounts() async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        try {
          QuerySnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('IR')
              .where('email', isEqualTo: user.email)
              .limit(1)
              .get();

          if (userSnapshot.docs.isEmpty) {
            print('User document not found');
            return;
          }

          String userIRID = userSnapshot.docs.first.get('irID');

          QuerySnapshot myProductsUnread = await FirebaseFirestore.instance
              .collection('notifications')
              .where('isRead', isEqualTo: false)
              .where('irID', isEqualTo: userIRID)
              .where('type', isEqualTo: 'my_products')
              .get();

          QuerySnapshot collectProductsUnread = await FirebaseFirestore.instance
              .collection('notifications')
              .where('isRead', isEqualTo: false)
              .where('collectorIRID', isEqualTo: userIRID)
              .where('type', isEqualTo: 'collect_products')
              .get();

          setState(() {
            _unreadMyProducts = myProductsUnread.docs.length;
            _unreadCollectProducts = collectProductsUnread.docs.length;
            NotificationTotal().totalUnreadCount = _unreadMyProducts + _unreadCollectProducts;
          });

          print("Unread My Products: $_unreadMyProducts");
          print("Unread Collect Products: $_unreadCollectProducts");
          print("Total Unread: ${NotificationTotal().totalUnreadCount}");
        } catch (error) {
          print("Error updating unread counts: $error");
        }
      }

      @override
      void dispose() {
        _tabController.dispose();
        super.dispose();
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color.fromARGB(111, 66, 144, 208),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'My Products',
                        style: TextStyle(
                          color: _tabController.index == 0 ? Colors.black : Colors.grey,
                        ),
                      ),
                      if (_unreadMyProducts > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$_unreadMyProducts',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Collect Products',
                        style: TextStyle(
                          color: _tabController.index == 1 ? Colors.black : Colors.grey,
                        ),
                      ),
                      
                      if (_unreadCollectProducts > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$_unreadCollectProducts',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              buildNotificationList('my_products'),
              buildNotificationList('collect_products'),
            ],
          ),
        );
      }

      Widget buildNotificationList(String type) {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          print('User not logged in');
          return const Center(child: Text('User not logged in'));
        }

        print('Building notification list for type: $type');
        print('Current user UID: ${user.uid}');

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('IR')
              .where('email',
                  isEqualTo: user.email) // Assume email is unique and exists in IR
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (userSnapshot.hasError) {
              print('Error fetching user data: ${userSnapshot.error}');
              return Center(child: Text('Error: ${userSnapshot.error}'));
            }

            if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
              print('User data not found');
              return const Center(child: Text('User data not found'));
            }

            print('User document data: ${userSnapshot.data!.docs.first.data()}');

            String userIRID = userSnapshot.data!.docs.first.get('irID');
            print('User IRID: $userIRID');

            Query notificationsQuery = FirebaseFirestore.instance
                .collection('notifications')
                .orderBy('timestamp', descending: true);

            if (type == 'my_products') {
              notificationsQuery = notificationsQuery
                  .where('irID', isEqualTo: userIRID)
                  .where('type', isEqualTo: 'my_products');
            } else if (type == 'collect_products') {
              notificationsQuery = notificationsQuery
                  .where('collectorIRID', isEqualTo: userIRID)
                  .where('type', isEqualTo: 'collect_products');
            }

            return StreamBuilder<QuerySnapshot>(
              stream: notificationsQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('Error in StreamBuilder: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  print('No notifications found for $type');
                  return Center(child: Text('No notifications for $type'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  print('No notifications found for $type');
                  // Update unread count to 0 for this type
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      if (type == 'my_products') {
                        _unreadMyProducts = 0;
                      } else if (type == 'collect_products') {
                        _unreadCollectProducts = 0;
                      }
                    });
                  });
                  return Center(child: Text('No notifications for $type'));
                }

                print(
                    'Number of notifications for $type: ${snapshot.data!.docs.length}');

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var notificationDoc = snapshot.data!.docs[index];
                    var notificationData =
                        notificationDoc.data() as Map<String, dynamic>;

                    print('Notification data: $notificationData');

                    var title = notificationData['title'] ?? 'No title';
                    var body = notificationData['body'] ?? 'No body';
                    var isRead = notificationData['isRead'] ?? false;
                    var timestamp = notificationData['timestamp'] as Timestamp?;

                    String timeString = '';
                    String dateString = '';
                    if (timestamp != null) {
                      timeString = DateFormat('HH:mm').format(timestamp.toDate());
                      dateString = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
                    }

                    return NotificationItem(
                      title: title,
                      body: body,
                      timeString: timeString,
                      dateString: dateString,
                      isRead: isRead,
                      onTap: () => markAsRead(notificationDoc),
                    );
                  },
                );
              },
            );
          },
        );
      }
    }

