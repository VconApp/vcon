// // //notification_service.dart
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// // class NotificationService {
// //   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
// //       FlutterLocalNotificationsPlugin();

// //   static void initialize() {
// //     final InitializationSettings initializationSettings =
// //         InitializationSettings(
// //       android: AndroidInitializationSettings("@mipmap/ic_launcher"),
// //     );

// //     _notificationsPlugin.initialize(initializationSettings);
// //   }

// //   static void display(RemoteMessage message) async {
// //     try {
// //       final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

// //       final NotificationDetails notificationDetails = NotificationDetails(
// //         android: AndroidNotificationDetails(
// //           "vcon_3rdparty_auth",
// //           "vcon_3rdparty_auth_channel",
// //           importance: Importance.max,
// //           priority: Priority.high,
// //         ),
// //       );

// //       await _notificationsPlugin.show(
// //         id,
// //         message.notification!.title,
// //         message.notification!.body,
// //         notificationDetails,
// //       );
// //     } on Exception catch (e) {
// //       print(e);
// //     }
// //   }
// // }

// //notification_service.dart
// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class NotificationService {
// //   static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
// //       FlutterLocalNotificationsPlugin();

// //   static void initialize() {
// //     const InitializationSettings initializationSettings = InitializationSettings(
// //       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
// //       iOS: DarwinInitializationSettings(),
// //     );

// //     _flutterLocalNotificationsPlugin.initialize(
// //       initializationSettings,
// //       onDidReceiveNotificationResponse: (NotificationResponse response) async {
// //         if (response.payload != null) {
// //           print('Notification payload: ${response.payload}');
// //         }
// //       },
// //     );
// //   }

// //   static void display(RemoteMessage message) async {
// //     try {
// //       final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
// //       const NotificationDetails notificationDetails = NotificationDetails(
// //         android: AndroidNotificationDetails(
// //           'high_importance_channel', // id
// //           'High Importance Notifications', // title
// //           importance: Importance.high,
// //         ),
// //         iOS: DarwinNotificationDetails(),
// //       );

// //       await _flutterLocalNotificationsPlugin.show(
// //         id,
// //         message.notification?.title,
// //         message.notification?.body,
// //         notificationDetails,
// //         payload: message.data['route'],
// //       );
// //     } on Exception catch (e) {
// //       print('Error displaying notification: $e');
// //     }
// //   }

// //   static Future<void> sendNotification(
// //       String userID, String title, String body, String type) async {
// //     await FirebaseFirestore.instance.collection('notifications').add({
// //       'userID': userID,
// //       'title': title,
// //       'body': body,
// //       'type': type, // 'my_products' or 'collect_products'
// //       'timestamp': FieldValue.serverTimestamp(),
// //     });
// //   }

// //   static Future<void> sendProductUpdateNotification(String userID) async {
// //     await sendNotification(
// //       userID,
// //       'Product Update',
// //       'Your product status has changed',
// //       'my_products',
// //     );
// //   }

// //   static Future<void> sendCollectionRequestNotification(String userID) async {
// //     await sendNotification(
// //       userID,
// //       'Collection Request',
// //       'You have a new collection request',
// //       'collect_products',
// //     );
// //   }
// // }

// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';

// // class NotificationService {
// //   static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
// //       FlutterLocalNotificationsPlugin();

// //   static void initialize() {
// //     const InitializationSettings initializationSettings = InitializationSettings(
// //       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
// //       iOS: DarwinInitializationSettings(),
// //     );

// //     _flutterLocalNotificationsPlugin.initialize(
// //       initializationSettings,
// //       onDidReceiveNotificationResponse: (NotificationResponse response) async {
// //         if (response.payload != null) {
// //           print('Notification payload: ${response.payload}');
// //         }
// //       },
// //     );
// //   }

// //   static void display(RemoteMessage message) async {
// //     try {
// //       final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
// //       const NotificationDetails notificationDetails = NotificationDetails(
// //         android: AndroidNotificationDetails(
// //           'high_importance_channel', // id
// //           'High Importance Notifications', // title
// //           importance: Importance.high,
// //         ),
// //         iOS: DarwinNotificationDetails(),
// //       );

// //       await _flutterLocalNotificationsPlugin.show(
// //         id,
// //         message.notification?.title,
// //         message.notification?.body,
// //         notificationDetails,
// //         payload: message.data['route'],
// //       );
// //     } on Exception catch (e) {
// //       print('Error displaying notification: $e');
// //     }
// //   }
// // }

// //notification_service.dart
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static void initialize() {
//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//       iOS: DarwinInitializationSettings(),
//     );

//     _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//         if (response.payload != null) {
//           print('Notification payload: ${response.payload}');
//           // Handle notification taps here
//         }
//       },
//     );
//   }

//   static void display(RemoteMessage message) async {
//     try {
//       final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//       const NotificationDetails notificationDetails = NotificationDetails(
//         android: AndroidNotificationDetails(
//           'high_importance_channel', // id
//           'High Importance Notifications', // title
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//         iOS: DarwinNotificationDetails(),
//       );

//       await _flutterLocalNotificationsPlugin.show(
//         id,
//         message.notification?.title,
//         message.notification?.body,
//         notificationDetails,
//         payload: message.data['route'],
//       );
//     } on Exception catch (e) {
//       print('Error displaying notification: $e');
//     }
//   }
// }


// notification_service.dart
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

//   static void initialize() {
//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: AndroidInitializationSettings("@mipmap/ic_launcher"),
//       iOS: DarwinInitializationSettings(),
//     );

//     _notificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//         if (response.payload != null) {
//           // Handle notification tap
//           print('Notification payload: ${response.payload}');
//         }
//       },
//     );
//   }

//   static Future<void> display(RemoteMessage message) async {
//     try {
//       final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//       const NotificationDetails notificationDetails = NotificationDetails(
//         android: AndroidNotificationDetails(
//           "high_importance_channel",
//           "High Importance Notifications",
//           channelDescription: "This channel is used for important notifications.",
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//         iOS: DarwinNotificationDetails(
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         ),
//       );

//       await _notificationsPlugin.show(
//         id,
//         message.notification?.title ?? 'Notification',
//         message.notification?.body ?? 'You have a new notification',
//         notificationDetails,
//         payload: message.data['route'],
//       );
//     } on Exception catch (e) {
//       print('Error displaying notification: $e');
//     }
//   }
// }

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          // Handle notification tap
          print('Notification payload: ${response.payload}');
        }
      },
    );
  }

  static Future<void> display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "high_importance_channel",
          "High Importance Notifications",
          channelDescription: "This channel is used for important notifications.",
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notificationsPlugin.show(
        id,
        message.notification?.title ?? 'Notification',
        message.notification?.body ?? 'You have a new notification',
        notificationDetails,
        payload: message.data['route'],
      );
    } on Exception catch (e) {
      print('Error displaying notification: $e');
    }
  }
}