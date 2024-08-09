// import 'package:onesignal_flutter/onesignal_flutter.dart';

// class OneSignalService {
//   static const String oneSignalAppId = '40418a90-aa30-451e-a850-8ff601bd7930';

//   static Future<void> initializeOneSignal() async {
//     // Initialize OneSignal
//     OneSignal.initialize(oneSignalAppId);
    
//     // Request permission to send push notifications
//     final permission = await OneSignal.Notifications.requestPermission(true);
//     print("Push notification permission granted: $permission");

//     // Set notification will show in foreground handler
//     OneSignal.Notifications.addForegroundWillDisplayListener((OSNotificationWillDisplayEvent event) {
//       // Will be called whenever a notification is received in foreground
//       // Display Notification, pass null param for not displaying the notification
//       event.notification.display();
//     });

//     // Set notification opened handler
//     OneSignal.Notifications.addClickListener((OSNotificationClickEvent event) {
//       // Will be called whenever a notification is opened/button pressed.
//       print('Notification opened: ${event.notification.body}');
//     });

//     // Set permission observer
//     OneSignal.Notifications.addPermissionObserver((bool changes) {
//       // Will be called whenever the permission changes
//       print("Permission state changed: $changes");
//     });
//   }
// }

// onesignal_service.dart
// onesignal_service.dart
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:crypto/crypto.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:get/get.dart';

// import 'package:vcon_3rdparty_auth/screens/notification.dart';

// class OneSignalService {
//   static Future<void> initializeOneSignal() async {
//     OneSignal.initialize('40418a90-aa30-451e-a850-8ff601bd7930');
//     OneSignal.Notifications.requestPermission(true);

//     // Add this to handle notification opening
//     OneSignal.Notifications.addClickListener((event) {
//       print("Notification clicked: ${event.notification.title}");
//       _handleNotificationClick(event.notification);
//     });
//   }

//   static void _handleNotificationClick(OSNotification notification) {
//     // Extract the notification type from the payload
//     String? notificationType = notification.additionalData?['type'];

//     // Navigate to the appropriate tab in the NotificationScreen
//     if (notificationType == 'my_products' || notificationType == 'collect_products') {
//       Get.to(() => NotificationScreen(initialTab: notificationType));
//     }
//   }

//   static String generateExternalUserIdAuthHash(String externalUserId, String restApiKey) {
//     var key = utf8.encode(restApiKey);
//     var bytes = utf8.encode(externalUserId);
//     var hmacSha256 = Hmac(sha256, key);
//     var digest = hmacSha256.convert(bytes);
//     return digest.toString();
//   }

//   static Future<void> createOneSignalUser(String externalUserId) async {
//     const String oneSignalAppId = '40418a90-aa30-451e-a850-8ff601bd7930';
//     const String restApiKey = 'NjczOWUxZTctMTUyZS00NDgwLTk4MDAtODcyNjM0ZTFhYTU3';

//     final String url = 'https://onesignal.com/api/v1/players';
//     final String authHash = generateExternalUserIdAuthHash(externalUserId, restApiKey);

//     try {
//       await OneSignal.login(externalUserId);
//       print('OneSignal external user ID set successfully');
//     } catch (e) {
//       print('Error setting OneSignal external user ID: $e');
//     }

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Basic $restApiKey',
//         },
//         body: json.encode({
//           'app_id': oneSignalAppId,
//           'external_user_id': externalUserId,
//           'external_user_id_auth_hash': authHash, // Add the auth hash here
//           'device_type': 1, // Specify device type (1 for Android, 0 for iOS)
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print('OneSignal user created successfully');
//       } else {
//         print('Failed to create OneSignal user. Status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       }
//     } catch (e) {
//       print('Error creating OneSignal user: $e');
//     }
//   }

//   static Future<void> sendOneSignalNotification(String externalUserId, String title, String message, String notificationType) async {
//     const String oneSignalAppId = '40418a90-aa30-451e-a850-8ff601bd7930';
//     const String restApiKey = 'NjczOWUxZTctMTUyZS00NDgwLTk4MDAtODcyNjM0ZTFhYTU3';

//     try {
//       print("Debug: Sending OneSignal notification to $externalUserId");
//       print("Debug: Title: $title");
//       print("Debug: Message: $message");
//       final response = await http.post(
//         Uri.parse('https://onesignal.com/api/v1/notifications'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Basic $restApiKey',
//         },
//         body: json.encode({
//           'app_id': oneSignalAppId,
//           'include_external_user_ids': [externalUserId],
//           'contents': {'en': message},
//           'headings': {'en': title},
//           'data': {'type': notificationType}, 
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('Debug: OneSignal notification sent successfully to $externalUserId');
//       } else {
//         print('Debug: Failed to send OneSignal notification to $externalUserId. Status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       }
//     } catch (e) {
//       print('Error sending OneSignal notification: $e');
//     }
//   }
// }

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:vcon_3rdparty_auth/screens/notification.dart';

class OneSignalService {
  static const String oneSignalAppId = '40418a90-aa30-451e-a850-8ff601bd7930';
  static const String restApiKey = 'NjczOWUxZTctMTUyZS00NDgwLTk4MDAtODcyNjM0ZTFhYTU3';

  static Future<void> initializeOneSignal() async {
    // Enable verbose logging for debugging
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Initialize OneSignal
    OneSignal.initialize(oneSignalAppId);
    
    // Request permission to send push notifications
    final permission = await OneSignal.Notifications.requestPermission(true);
    print("Push notification permission granted: $permission");

    // Set notification will show in foreground handler
    OneSignal.Notifications.addForegroundWillDisplayListener((OSNotificationWillDisplayEvent event) {
      // Will be called whenever a notification is received in foreground
      // Display Notification, pass null param for not displaying the notification
      event.notification.display();
    });

    // Set notification opened handler
    OneSignal.Notifications.addClickListener((OSNotificationClickEvent event) {
      // Will be called whenever a notification is opened/button pressed.
      print('Notification opened: ${event.notification.body}');
      _handleNotificationClick(event.notification);
    });

    // Set permission observer
    OneSignal.Notifications.addPermissionObserver((bool changes) {
      // Will be called whenever the permission changes
      print("Permission state changed: $changes");
    });
  }

  static void _handleNotificationClick(OSNotification notification) {
    // Extract the notification type from the payload
    String? notificationType = notification.additionalData?['type'];

    // Navigate to the appropriate tab in the NotificationScreen
    if (notificationType == 'my_products' || notificationType == 'collect_products') {
      Get.to(() => NotificationScreen(initialTab: notificationType));
    }
  }

  static String generateExternalUserIdAuthHash(String externalUserId, String restApiKey) {
    var key = utf8.encode(restApiKey);
    var bytes = utf8.encode(externalUserId);
    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  static Future<void> createOneSignalUser(String externalUserId) async {
    final String authHash = generateExternalUserIdAuthHash(externalUserId, restApiKey);

    try {
      await OneSignal.login(externalUserId);
      print('OneSignal external user ID set successfully');
    } catch (e) {
      print('Error setting OneSignal external user ID: $e');
    }

    try {
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/players'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $restApiKey',
        },
        body: json.encode({
          'app_id': oneSignalAppId,
          'external_user_id': externalUserId,
          'external_user_id_auth_hash': authHash,
          'device_type': defaultTargetPlatform == TargetPlatform.iOS ? 0 : 1, // 0 for iOS, 1 for Android
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('OneSignal user created successfully');
      } else {
        print('Failed to create OneSignal user. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error creating OneSignal user: $e');
    }
  }

  static Future<void> sendOneSignalNotification(String externalUserId, String title, String message, String notificationType) async {
    try {
      print("Debug: Sending OneSignal notification to $externalUserId");
      print("Debug: Title: $title");
      print("Debug: Message: $message");
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
        print('Debug: OneSignal notification sent successfully to $externalUserId');
      } else {
        print('Debug: Failed to send OneSignal notification to $externalUserId. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending OneSignal notification: $e');
    }
  }
}