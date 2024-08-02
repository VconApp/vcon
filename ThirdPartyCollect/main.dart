// //Second
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'firebase_options.dart';

// // import 'package:vcon_3rdparty_auth/screens/login.dart';

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp(
// //     options: DefaultFirebaseOptions.currentPlatform,
// //   );
// //   runApp(const App());
// // }

// // class App extends StatelessWidget {
// //   const App({Key? key}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = ThemeData(
// //       primarySwatch: Colors.blue, // Sets the primary color and its shades
// //       primaryColor: Colors.white, // Sets the primary color directly
// //       backgroundColor: Colors.white, // Sets the background color
// //       // Additional theme configurations like text styles, fonts, etc.
// //       textTheme: GoogleFonts.latoTextTheme(),
// //       appBarTheme: const AppBarTheme(
// //         backgroundColor: Colors.white, // Set app bar background color
// //         foregroundColor: Colors.black, // Set app bar text color
// //       ),
// //       floatingActionButtonTheme: const FloatingActionButtonThemeData(
// //         backgroundColor: Colors.blue, // Set FAB background color
// //         foregroundColor: Colors.white, // Set FAB icon color
// //       ),
// //       elevatedButtonTheme: ElevatedButtonThemeData(
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: const Color.fromARGB(255, 157, 42, 42), // Set default button color
// //           foregroundColor: Colors.white, // Set default text color
// //         ),
// //       ),
// //     );

// //     return MaterialApp(
// //       themeMode: ThemeMode.system,
// //       theme: theme, // Apply your custom theme here
// //       home: const LoginScreen(),
// //     );
// //   }
// // }

// //First
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'firebase_options.dart';

// // import 'package:vcon_3rdparty_auth/screens/login.dart';

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp(
// //     options: DefaultFirebaseOptions.currentPlatform,
// //   );
// //   runApp(const App());
// // }

// // class App extends StatelessWidget {
// //   const App({Key? key}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = ThemeData(
// //       primarySwatch: Colors.blue, // Sets the primary color and its shades
// //       // Optionally, set primary color directly:
// //       primaryColor: Colors.white,
// //       backgroundColor: Colors.white, // Sets the background color
// //       // Additional theme configurations like text styles, fonts, etc.
// //       textTheme: GoogleFonts.latoTextTheme(),
// //     );

// //     return MaterialApp(
// //       themeMode: ThemeMode.system,
// //       theme: theme, // Apply your custom theme here
// //       home: const LoginScreen(),
// //     );
// //   }
// // }


// //main.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:vcon_3rdparty_auth/auth_controller.dart';
// import 'package:vcon_3rdparty_auth/screens/login.dart';
// import 'package:vcon_3rdparty_auth/notification_service.dart'; // Make sure to create this file
// import 'firebase_options.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("Handling a background message: ${message.messageId}");
// }

// void getToken() async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   String? token = await messaging.getToken();
//   print("FCM Token: $token");
//   // You can now use this token to send notifications
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   // Initialize the AuthController using GetX
//   Get.put(AuthController());

//   // Set up Firebase Cloud Messaging
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   // Initialize notification service
//   NotificationService.initialize();

//   // Get the FCM token
//   getToken();

//   // Set up foreground message handling
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print('Got a message whilst in the foreground!');
//     print('Message data: ${message.data}');

//     if (message.notification != null) {
//       print('Message also contained a notification: ${message.notification}');
//       NotificationService.display(message);
//     }
//   });

//   runApp(const App());
// }

// class App extends StatelessWidget {
//   const App({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final theme = ThemeData(
//       primarySwatch: Colors.blue,
//       primaryColor: Colors.white,
//       backgroundColor: Colors.white,
//       textTheme: GoogleFonts.latoTextTheme(),
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       floatingActionButtonTheme: const FloatingActionButtonThemeData(
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color.fromARGB(255, 157, 42, 42),
//           foregroundColor: Colors.white,
//         ),
//       ),
//     );

//     return GetMaterialApp(
//       themeMode: ThemeMode.system,
//       theme: theme,
//       home: const LoginScreen(),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:vcon_3rdparty_auth/auth_controller.dart';
// import 'package:vcon_3rdparty_auth/screens/login.dart';
// import 'package:vcon_3rdparty_auth/notification_service.dart'; // Make sure to create this file
// import 'firebase_options.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("Handling a background message: ${message.messageId}");
// }

// void getToken() async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   String? token = await messaging.getToken();
//   print("FCM Token: $token");
//   // You can now use this token to send notifications
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   // Initialize the AuthController using GetX
//   Get.put(AuthController());

//   // Set up Firebase Cloud Messaging
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   // Initialize notification service
//   NotificationService.initialize();

//   // Get the FCM token
//   getToken();

//   // Set up foreground message handling
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print('Got a message whilst in the foreground!');
//     print('Message data: ${message.data}');

//     if (message.notification != null) {
//       print('Message also contained a notification: ${message.notification}');
//       NotificationService.display(message);
//     }
//   });

//   runApp(const App());
// }

// class App extends StatelessWidget {
//   const App({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final theme = ThemeData(
//       primarySwatch: Colors.blue,
//       primaryColor: Colors.white,
//       backgroundColor: Colors.white,
//       textTheme: GoogleFonts.latoTextTheme(),
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       floatingActionButtonTheme: const FloatingActionButtonThemeData(
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color.fromARGB(255, 157, 42, 42),
//           foregroundColor: Colors.white,
//         ),
//       ),
//     );

//     return GetMaterialApp(
//       themeMode: ThemeMode.system,
//       theme: theme,
//       home: const LoginScreen(),
//     );
//   }
// }


//main.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:vcon_3rdparty_auth/auth_controller.dart';
// import 'package:vcon_3rdparty_auth/screens/login.dart';
// import 'package:vcon_3rdparty_auth/notification_service.dart';
// import 'firebase_options.dart';

// // Conditional import for dart:js
// import 'dart:async';
// // ignore: avoid_web_libraries_in_flutter
// import 'dart:html' if (dart.library.io) 'dart:io';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("Handling a background message: ${message.messageId}");
// }

// void getToken() async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   try {
//     String? token = await messaging.getToken();
//     print("FCM Token: $token");
//   } catch (e) {
//     print("Error getting FCM token: $e");
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   Get.put(AuthController());

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   NotificationService.initialize();
//   getToken();

//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print('Got a message whilst in the foreground!');
//     print('Message data: ${message.data}');

//     if (message.notification != null) {
//       print('Message also contained a notification: ${message.notification}');
//       NotificationService.display(message);
//     }
//   });

//   runApp(const App());
// }

// class App extends StatelessWidget {
//   const App({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final theme = ThemeData(
//       primarySwatch: Colors.blue,
//       primaryColor: Colors.white,
//       scaffoldBackgroundColor: Colors.white,
//       textTheme: GoogleFonts.latoTextTheme(),
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       floatingActionButtonTheme: const FloatingActionButtonThemeData(
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color.fromARGB(255, 157, 42, 42),
//           foregroundColor: Colors.white,
//         ),
//       ),
//     );

//     return GetMaterialApp(
//       themeMode: ThemeMode.system,
//       theme: theme,
//       home: const LoginScreen(),
//     );
//   }
// }

// // Example of how to use JavaScript functionality conditionally
// void callJavaScriptFunction() {
//   if (kIsWeb) {
//     // Use JavaScript interop here
//     // For example:
//     // js.context.callMethod('alert', ['Hello from Dart!']);
//   } else {
//     print('JavaScript interop is not available on this platform');
//   }
// }

// //main.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:vcon_3rdparty_auth/auth_controller.dart';
// import 'package:vcon_3rdparty_auth/screens/login.dart';
// import 'package:vcon_3rdparty_auth/notification_service.dart';
// import 'firebase_options.dart';

// // Conditional import for dart:js
// import 'dart:async';
// // ignore: avoid_web_libraries_in_flutter
// import 'dart:html' if (dart.library.io) 'dart:io';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("Handling a background message: ${message.messageId}");
// }

// void getToken() async {
//   print("getToken function called");
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   try {
//     if (!kIsWeb) {
//       print("Requesting permission for push notifications...");
//       NotificationSettings settings = await messaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//       print("Authorization status: ${settings.authorizationStatus}");
      
//       if (settings.authorizationStatus != AuthorizationStatus.authorized) {
//         print("Push notifications not authorized");
//         return;
//       }
//     }
    
//     print("Attempting to get FCM token...");
//     String? token = await messaging.getToken();
//     if (token != null) {
//       print("FCM Token: $token");
//     } else {
//       print("Failed to get FCM token. Token is null.");
//     }
//   } catch (e) {
//     print("Error getting FCM token: $e");
//     if (e is FirebaseException) {
//       print("Firebase Exception Code: ${e.code}");
//       print("Firebase Exception Message: ${e.message}");
//     }
//   }
// }

// void saveTokenToFirestore(String token) async {
//   String? userID = FirebaseAuth.instance.currentUser?.uid;
//   if (userID != null) {
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(userID)
//         .set({'fcmToken': token}, SetOptions(merge: true));
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   Get.put(AuthController());

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   NotificationService.initialize();
//   getToken();

//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print('Got a message whilst in the foreground!');
//     print('Message data: ${message.data}');

//     if (message.notification != null) {
//       print('Message also contained a notification: ${message.notification}');
//       NotificationService.display(message);
//     }
//   });

//   runApp(const App());
// }

// class App extends StatelessWidget {
//   const App({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final theme = ThemeData(
//       primarySwatch: Colors.blue,
//       primaryColor: Colors.white,
//       scaffoldBackgroundColor: Colors.white,
//       textTheme: GoogleFonts.latoTextTheme(),
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       floatingActionButtonTheme: const FloatingActionButtonThemeData(
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color.fromARGB(255, 157, 42, 42),
//           foregroundColor: Colors.white,
//         ),
//       ),
//     );

//     return GetMaterialApp(
//       themeMode: ThemeMode.system,
//       theme: theme,
//       home: const LoginScreen(),
//     );
//   }
// }

// // Example of how to use JavaScript functionality conditionally
// void callJavaScriptFunction() {
//   if (kIsWeb) {
//     // Use JavaScript interop here
//     // For example:
//     // js.context.callMethod('alert', ['Hello from Dart!']);
//   } else {
//     print('JavaScript interop is not available on this platform');
//   }
// }

//30/7/2024
// //main.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import 'package:vcon_3rdparty_auth/auth_controller.dart';
// import 'package:vcon_3rdparty_auth/screens/login.dart';
// import 'package:vcon_3rdparty_auth/notification_service.dart';
// import 'firebase_options.dart';

// // Remove this conditional import as it's not needed
// // import 'dart:html' if (dart.library.io) 'dart:io';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   print("Handling a background message: ${message.messageId}");
//   await NotificationService.display(message);
// }

// void setupPushNotifications() async {
//   final fcm = FirebaseMessaging.instance;
  
//   if (!kIsWeb) {
//     print("Requesting permission for push notifications...");
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//     NotificationSettings settings = await fcm.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     print("Authorization status: ${settings.authorizationStatus}");
    
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       String? token = await fcm.getToken();
//       if (token != null) {
//         print("FCM Token: $token");
//         saveTokenToFirestore(token);
//       } else {
//         print("Failed to get FCM token. Token is null.");
//       }

//       // Handle token refreshes
//       FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToFirestore);
//     } else {
//       print("Push notifications not authorized");
//     }
//   }
// }

// void saveTokenToFirestore(String token) async {
//   String? userID = FirebaseAuth.instance.currentUser?.uid;
//   if (userID != null) {
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(userID)
//         .set({'fcmToken': token}, SetOptions(merge: true));
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   Get.put(AuthController());

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   NotificationService.initialize();
//   setupPushNotifications();

//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print('Got a message whilst in the foreground!');
//     print('Message data: ${message.data}');

//     if (message.notification != null) {
//       print('Message also contained a notification: ${message.notification}');
//       NotificationService.display(message);
//     }
//   });

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
   
//   runApp(const App());
// }

// class App extends StatelessWidget {
//   const App({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final theme = ThemeData(
//       primarySwatch: Colors.blue,
//       primaryColor: Colors.white,
//       scaffoldBackgroundColor: Colors.white,
//       textTheme: GoogleFonts.latoTextTheme(),
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       floatingActionButtonTheme: const FloatingActionButtonThemeData(
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color.fromARGB(255, 157, 42, 42),
//           foregroundColor: Colors.white,
//         ),
//       ),
//     );

//     return GetMaterialApp(
//       themeMode: ThemeMode.system,
//       theme: theme,
//       home: const LoginScreen(),
//     );
//   }
// }

//main,dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:vcon_3rdparty_auth/auth_controller.dart';
import 'package:vcon_3rdparty_auth/screens/login.dart';
import 'package:vcon_3rdparty_auth/notification_service.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  print("Handling a background message: ${message.messageId}");
  await NotificationService.display(message);
}

Future<void> setupPushNotifications() async {
  final fcm = FirebaseMessaging.instance;
  
  if (!kIsWeb) {
    print("Not running on web, proceeding with push notification setup");
    print("Requesting permission for push notifications...");
    NotificationSettings settings = await fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print("Authorization status: ${settings.authorizationStatus}");
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await fcm.getToken();
      print("FCM Token (regardless of login status): $token");
      if (token != null) {
        print("FCM Token: $token");
        await saveTokenToFirestore(token);
      } else {
        print("Failed to get FCM token. Token is null.");
      }

      // Handle token refreshes
      FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToFirestore);
    } else {
      print("Running on web, skipping push notification setup");
      print("Push notifications not authorized");
    }
  }
}

Future<void> saveTokenToFirestore(String token) async {
  String? userID = FirebaseAuth.instance.currentUser?.uid;
  if (userID != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .set({'fcmToken': token}, SetOptions(merge: true));
    print("FCM token saved to Firestore for user: $userID");
  } else {
    print("Failed to save FCM token: User is not logged in.");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Firebase initialized successfully");

  Get.put(AuthController());

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await NotificationService.initialize();
  try {
    await setupPushNotifications();
  } catch (e) {
    print("Error setting up push notifications: $e");
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      NotificationService.display(message);
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    // Handle any specific logic for when the app is opened from a notification
  });
   
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.latoTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 157, 42, 42),
          foregroundColor: Colors.white,
        ),
      ),
    );

    return GetMaterialApp(
      themeMode: ThemeMode.system,
      theme: theme,
      home: const LoginScreen(),
    );
  }
}